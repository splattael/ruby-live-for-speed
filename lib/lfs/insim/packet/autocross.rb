module LFS
  module Parser
    module Packet

      define_packet :AXI, 40 do
        byte :start_position
        byte :checkpoints
        word :objects
        
        char :layout_name, :length => 32
      end

      define_packet :AXO, 4 do
      end

    end
  end
end
