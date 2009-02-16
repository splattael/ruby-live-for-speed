module LFS
  module Parser
    module Packet

      define_packet :CCH, 8 do
        byte :camera
        byte spare
        byte spare
        byte spare
      end

    end
  end
end
