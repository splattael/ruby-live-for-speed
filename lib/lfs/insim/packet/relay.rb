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

      define_packet :HLR, 4 do
      end

      define_packet :HOS do
        array :host_infos, :type => :host_info, :read_until => lambda {|v| index + 1 >= header.first_byte }

        def number_of_hosts
          header.first_byte
        end
      end

      define_packet :SEL, 68 do
        string :hostname, :length => 32
        string :admin_password, :length => 16
        string :spectator_password, :length => 16
      end

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
