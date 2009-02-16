module LFS
  module Parser
    module Packet
      define_packet :MSO, 136 do
        byte :connection_id
        byte :player_id
        byte :player_type
        byte :text_start

        char :message, :length => 128
      end
    end
  end
end
