module LFS
  module Parser
    module Packet

      define_packet :BFN, 8 do
        byte :connection_id
        byte :click_id
        byte :internal
        byte spare
      end

      define_packet :BTN do
        byte :click_id
        byte :flags
        byte :style
        byte :input_max_size
        
        byte :left
        byte :top
        byte :width
        byte :height

        char :text, :read_length => proc { header.packet_size - 12 } # TODO
      end

      define_packet :BTC, 8 do
        byte :click_id
        byte :flags
        byte :click_flags
        byte spare
      end

      define_packet :BTT, 104 do
        byte :click_id
        byte :flags
        byte :input_max_size
        byte spare

        char :text, :length => 96
      end

    end
  end
end
