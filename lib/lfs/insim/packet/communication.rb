module LFS
  module Parser
    module Packet
      # Initialize InSim connection
      define_packet :ISI, 44 do
        word :udpport
        word :flags,                :initial_value => 32 # TODO

        byte :_sp1
        byte :host_message_prefix
        word :interval,             :initial_value => 0

        char :admin_password,       :length => 16
        char :program_name,         :length => 16
      end

      define_packet :VER, 20 do
        char :version, :length => 8
        char :product, :length => 6
        word :insim_version
      end
    end
  end
end
