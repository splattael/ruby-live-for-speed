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
        byte :_sp1
        byte :penalty # TODO
        byte :pit_stops
        byte :_sp2
      end

      define_packet :SPX, 16 do
        include PlayerId
        time :lap_time
        time :total_time
        byte :split
        byte :penalty # TODO
        byte :pit_stops
        byte :_sp1
      end

      define_packet :FLG, 8 do
        include PlayerId

        byte :enabled
        byte :flag
        byte :car_behind
        byte :_sp1
      end
    end
  end
end
