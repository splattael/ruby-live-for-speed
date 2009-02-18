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

      define_packet :FIN, 20 do
        unsigned :total_time
        unsigned :best_lap

        byte spare
        byte :stops
        byte :confirm
        byte spare

        word :laps_done
        word :flags
      end

      define_packet :RST, 28 do
        byte :race_laps
        byte :qual_mins
        byte :players
        byte spare

        char :track, :length => 6
        byte :weather
        byte :wind
        
        word :flags
        word :nodes
        word :finish_node
        word :split1_node
        word :split2_node
        word :split3_node
      end

      define_packet :RES, 84 do
        char :username,     :length => 24
        char :nickname,     :length => 24
        char :plate,        :length => 8
        char :skin_prefix,  :length => 4

        unsigned :total_time
        unsigned :best_lap

        byte spare
        byte :stops
        byte :confirm
        byte spare

        word :laps_done
        word :flags

        byte :result_position
        byte :total_results
        word :penalty_added
      end

      define_packet :REO, 36 do
        def number_of_players
          first_byte
        end

        array :player_ids, :type => :byte, :initial_length => 32
      end

      define_packet :PEN, 8 do
        byte :old_penalty
        byte :new_penalty
        byte :rease
        byte spare
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

      define_packet :VTN, 8 do
        byte :connection_id
        byte :action
        byte spare
        byte spare
      end

      define_packet :PFL, 8 do
        word :flags
        word spare
      end

    end
  end
end
