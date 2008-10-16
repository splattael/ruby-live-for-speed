module LFS
  module Parser
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
          puts ">>> #{packet.inspect}" if $DEBUG
          packet
        end
      end

      @packet_classes = {}
      def self.register(packet_type, packet_class)
        puts "registering #{packet_class} (#{packet_type.inspect})" if $DEBUG
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
    end
  end
end
