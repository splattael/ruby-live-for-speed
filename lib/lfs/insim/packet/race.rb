module LFS
  module Parser
    module Packet
      # race
      module PlayerId
        def player_id; first_byte end
      end

      define_packet :LAP, 20 do
        include PlayerId
        time :lap_time
        time :total_time
        word :laps_done
        word :flags # TODO
        byte spare
        byte :penalty # TODO
        byte :pit_stops
        byte spare
      end

      define_packet :SPX, 16 do
        include PlayerId
        time :lap_time
        time :total_time
        byte :split
        byte :penalty # TODO
        byte :pit_stops
        byte spare
      end

      define_packet :FLG, 8 do
        include PlayerId

        byte :enabled
        byte :flag
        byte :car_behind
        byte spare
      end

      define_packet :PLA, 8 do
        byte :fact
        byte spare
        byte spare
        byte spare
      end

      define_packet :PIT, 24 do
        word :laps_done
        word :flags

        byte spare
        byte :penalty
        byte :pitstops
        byte spare

        tyres :tyres
        
        unsigned :work
        unsigned spare
      end

      define_packet :PSF, 12 do
        unsigned :stop_time
        unsigned spare
      end

      define_packet :STA, 28 do
        float :replay_speed

        word :flags
        byte :cam
        byte :view_player_id

        byte :in_race
        byte :connections
        byte :finished
        byte :race_in_progress

        byte :qualmins
        byte :laps
        byte spare
        byte spare

        char :track, :length => 6
        byte :weather
        byte :wind
      end
    end
  end
end
