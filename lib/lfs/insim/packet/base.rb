module LFS
  module Parser
    module Packet
      def self.Packet(type=nil, size=nil)
        # TODO really?
        klass = Class.new(Base)
        klass.packet_type = type
        klass.packet_size = size
        klass
      end

      # Base
      class Base < ::BinData::MultiValue
        attr_accessor :header

        endian :little

        class << self
          def inherited(subclass)
            if packet_type
              # TODO ugly hack
              subclass.packet_type = packet_type
              subclass.packet_size = packet_size
              ::LFS::Parser::Packet.register(packet_type, subclass)
            end
          end

          attr_accessor :packet_type
          attr_accessor :packet_size
        end

        def write(io)
          header.write(io)
          super(io)
        end

        def packet_size
          header.packet_size
        end

        def packet_type
          self.class.packet_type
        end

        def typed?(symbol)
          packet_type == symbol
        end

        def prepare_to_write(args={})
          self.header = Header.new
          self.header.packet_size = self.class.packet_size
          self.header.packet_type = ::LFS::Parser::Enum::PacketType[self.class.packet_type].to_i
          self.header.request = 1
          propagate_values(args)
        end

        def inspect_header
          ""
        end

        def inspect_fields
        end

        def inspect
          enum = 
          s = "#<#{packet_type}:"
          s += inspect_header
          if inspect_fields
            s += inspect_fields.inject({}) {|hash, key| hash[key] = send(:"#{key}=") }.inspect
          end
          s += snapshot.inspect
          s += ">"
          s 
        end

        private
        def propagate_values(args={})
          args.each do |key, value|
            method = :"#{key}="
            send(method, value) if respond_to?(method)
          end
        end
      end

      class Header < ::BinData::MultiValue
        SIZE = 4

        byte :packet_size
        byte :packet_type
        byte :request
        byte :first_byte
      end

      # Unknown, raw packet
      class Unknown < Packet(:UNKN)
        string :data, :length => proc { packet_size - 4 }

        def inspect_header
          header.snapshot.inspect
        end
      end

      # tiny
      class Tiny < ::BinData::MultiValue
        def subtype
          ::LFS::Parser::Enum::Tiny[first_byte]
        end

        def subtype=(type)
          self.first_byte = ::LFS::Parser::Enum::Tiny[first_byte].to_i
        end

        def subtyped?(type)
          subtype == ::LFS::Parser::Enum::Tiny[first_byte]
        end
      end

    end
  end
end
