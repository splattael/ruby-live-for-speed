require 'lfs/packet_enums.rb'

module LFS
  module Parser
    # Basic Types
    module Type
      class Char < ::BinData::SingleValue
        string :char, :trim_value => true, :read_length => :length

        mandatory_parameter :length

        def length; @params[:length] end

        def get; self.char end
        def set(v); self.char = v end
      end

      class Byte < ::BinData::SingleValue
        uint8 :byte, :length => 1

        def get; self.byte end
        def set(v); self.byte = v end
      end

      class Word < ::BinData::SingleValue
        string :word, :length => 2

        def get; self.word end
        def set(v); self.word = v end
      end
    end

    # Packet
    module Packet
      class Factory
        def initialize
          @header = Header.new
        end

        def read(io)
          bytes = io.read(Header::SIZE).unpack("C4")
          @header.packet_size = bytes[0]
          @header.packet_type = bytes[1]
          @header.request = bytes[2]
          @header.first_byte = bytes[3]
          read_packet(io)
        end

        def read_packet(io)
          packet_class = Packet.lookup(@header.packet_type) || Unknown
          packet = packet_class.new
          packet.header = @header
          packet.read(io)
          puts ">>> #{packet.inspect}"
          packet
        end
      end

      @packet_classes = {}
      def self.register(packet_type, packet_class)
        puts "registering #{packet_class} (#{packet_type.inspect})"
        enum = packet_type_enum_for(packet_type)
        @packet_classes[enum] = packet_class
      end

      def self.packet_type_enum_for(thingy)
        ::LFS::Parser::Enum::PacketType[thingy]
      end

      def self.lookup(packet_type)
        enum = packet_type_enum_for(packet_type)
        @packet_classes[enum]
      end

      def self.create(packet_type, args={})
        packet_class = lookup(packet_type) or raise "unknown #{packet_type}(#{args.inspect})"
        packet = packet_class.new
        packet.prepare_to_write(args)
        packet
      end

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
              # puts "inherited by #{subclass} => #{packet_size}/#{packet_type}"
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
          # TODO
          first_byte
        end
      end

      # init
      class InSimInit < Packet(:ISI, 44)
        word :udpport
        word :flags, :initial_value => 32
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

      # relay
      class HostInfo < ::BinData::MultiValue
        char :hostname, :length => 32
        char :track, :length => 6
        byte :flags
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
