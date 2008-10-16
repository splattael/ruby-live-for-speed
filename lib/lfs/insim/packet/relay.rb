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

      class HostListRequest < Packet(:HLR, 4)
      end

      class HostListResponse < Packet(:HOS)
        array :host_infos, :type => :host_info, :read_until => proc { index + 1 >= number_of_hosts }

        def number_of_hosts
          header.first_byte
        end
      end

      class SelectRelayHost < Packet(:SEL, 68)
        string :hostname, :length => 32
        string :admin_password, :length => 16
        string :spectator_password, :length => 16
      end

      class RelayError < Packet(:ERR, 4)
        def error
          ::LFS::Parser::Enum::RelayError[first_byte]
        end
      end
    end
  end
end
