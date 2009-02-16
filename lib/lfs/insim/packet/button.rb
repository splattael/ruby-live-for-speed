module LFS
  module Parser
    module Packet

      define_packet :BFN, 8 do
        byte :connection_id
        byte :click_id
        byte :internal
        byte spare
      end

    end
  end
end
