module LFS
  module Parser
    module Packet
      # race
      module PlayerId
        def player_id; first_byte end
      end

      class Lap < Packet(:LAP, 20)
        include PlayerId
        time :lap_time
        time :total_time
        word :laps_done
        word :flags # TODO
        byte :spare0
        byte :penalty # TODO
        byte :pit_stops
        byte :spare1
      end

      class Split < Packet(:SPX, 16)
        include PlayerId
        time :lap_time
        time :total_time
        byte :split
        byte :penalty # TODO
        byte :pit_stops
        byte :spare1
      end
    end
  end
end
