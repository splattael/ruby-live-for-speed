module LFS
  module Parser
    module Packet

      # defines a packet class
      def self.define_packet(type, size = nil, &block)
        klass = Class.new(Base) do
          def self.name
            packet_type
          end
        end
        klass.class_eval(&block) if block
        klass.packet_type = type
        klass.packet_size = size
        ::LFS::Parser::Packet.register(type, klass)
        klass
      end

      # Base
      class Base < ::BinData::Record
        include Helper

        attr_accessor :header
        endian :little

        class << self
          attr_accessor :packet_type
          attr_accessor :packet_size

        end

        def self.create(args={})
          packet = new
          packet.prepare_to_write(args)
          packet
        end

        def write(io)
          # reevaluate packet_size
          header.packet_size = self.class.packet_size || packet_size
          header.write(io)
          super(io)
        end

        def packet_size
          header.packet_size
        end

        def packet_type
          self.class.packet_type
        end

        def prepare_to_write(args={})
          self.header = Header.new
          header.packet_size = self.class.packet_size || packet_size
          header.packet_type = ::LFS::Parser::Enum::PacketType[self.class.packet_type].to_i
          header.request = args[:request] || 1
          propagate_values(args)
        end

        def ===(other)
          packet_type == other || super(other)
        end

        def inspect_header
          $DEBUG ? header.inspect : ""
        end

        def inspect_fields
        end

        def first_byte; header.first_byte end
        def first_byte=(b); header.first_byte = b end
        def request; header.request end
        def request=(b); header.request = b end

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

      class Header < ::BinData::Record
        SIZE = 4

        byte :packet_size
        byte :packet_type
        byte :request
        byte :first_byte
      end

      # Unknown, raw packet
      define_packet :UNKN do
        string :data, :length => proc { packet_size - Header::SIZE }

        def inspect_header
          header.inspect
        end
      end

      # tiny
      define_packet :TINY, 4 do
        def ===(other)
          :"#{packet_type}_#{subtype.symbol}" == other || super(other)
        end

        def subtype
          ::LFS::Parser::Tiny[first_byte]
        end

        def subtype=(type)
          self.first_byte = ::LFS::Parser::Tiny[type].to_i
        end

      end

      # small
      define_packet :SMALL, 8 do
        unsigned :data

        def ===(other)
          :"#{packet_type}_#{subtype.symbol}" == other || super(other)
        end

        def subtype
          ::LFS::Parser::Small[first_byte]
        end

        def subtype=(type)
          self.first_byte = ::LFS::Parser::Small[type].to_i
        end
     end

    end
  end
end
