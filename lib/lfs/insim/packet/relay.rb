module LFS
  module Parser
    module Packet

      # relay
      class HostInfo < ::BinData::MultiValue
        char :hostname, :length => 32
        char :track, :length => 6
        byte :flags # TODO
        byte :connections
      end

      # // HostList Request
      define_packet :HLR, 4 do
      end

      # // Hostlist (hosts connected to the Relay)
      define_packet :HOS do
        first_byte_is :number_of_hosts

        array :host_infos, :type => :host_info,
              :read_until => lambda {|v| index + 1 >= number_of_hosts }
      end

      # // Relay select - packet to select a host, so relay starts sending you data.
      define_packet :SEL, 68 do
        string :hostname, :length => 32
        string :admin_password, :length => 16
        string :spectator_password, :length => 16
      end

      # // If you specify a wrong value, like invalid packet / hostname / adminpass / specpass, 
      # // the Relay returns an error packet :
      define_packet :ERR, 4 do
        def error
          ::LFS::Parser::Enum::RelayError[first_byte]
        end

        def inspect
          error
        end
      end
    end
  end
end
