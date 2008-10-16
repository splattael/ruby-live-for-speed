module LFS
  module Parser
    module Packet
      # Initialize InSim connection
      class InSimInit < Packet(:ISI, 44)
        word :udpport
        word :flags, :initial_value => 32 # TODO
        byte :spare0
        byte :host_message_prefix
        word :interval, :initial_value => 100
        char :admin_password, :length => 16
        char :program_name, :length => 16
      end

      class InSimVersion < Packet(:VER, 20)
        char :version, :length => 8
        char :product, :length => 6
        word :insim_version
      end
    end
  end
end
