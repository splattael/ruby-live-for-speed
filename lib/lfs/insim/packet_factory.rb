module LFS
  module Parser
    # Packet
    module Packet
      class Factory
        def initialize
          @header = Header.new
          @cache = {}
        end

        def read(io)
          @header.read(io)
          p @header if $DEBUG
          read_packet(io)
        end

        def read_packet(io)
          packet_class = Packet.lookup(@header.packet_type) || Packet.lookup(:UNKN)
          packet = (@cache[packet_class] ||= packet_class.new)
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

      def self.unregister(*packet_types)
        packet_types.map do |type|
          @packet_classes.delete(packet_type_enum_for(type))
        end
      end

      def self.packet_type_enum_for(thingy)
        ::LFS::Parser::Enum::PacketType[thingy]
      end

      def self.lookup(packet_type)
        enum = packet_type_enum_for(packet_type)
        @packet_classes[enum]
      end

      def self.each_packet_class(&block)
        @packet_classes.each(&block)
      end

      def self.create(packet_type, args={})
        packet_class = lookup(packet_type) or raise "unknown #{packet_type}(#{args.inspect})"
        packet_class.create(args)
      end
    end
  end
end
