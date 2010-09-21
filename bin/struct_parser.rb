require 'rubygems'
require 'extlib'
require 'pp'

class StructParser
  attr_reader :packets, :bit_enums, :enums

  COMMENT = "(?:\s*//\s*(.*))?"

  def initialize(file)
    @packets = []
    @bit_enums = {}
    @enums = {}

    File.open(ARGV[0]) do |file|
      @content = file.read
      # @content.gsub!(%r{\s*//.*$}, '')
      @content.gsub!(/[\r]|^\t/, '')
      @content.gsub!(/[\t]/, ' ')
      parse
    end
  end

  private

  def parse
    parse_packets
    parse_enums
    parse_bit_enums
  end

  def parse_packets
    # struct TYPE {
    #   type fieldname;
    #   type varfieldname[123];
    # }
    @content.scan(/^struct\s+(\S+)(.*?)?\{(.*?)\}/m) do |packet_name, packet_comment, body|
      packet_comment.gsub!('//', '')
      packet = Packet.new(packet_name, packet_comment.to_s.chomp)
      body.scan(%r{\s*(\S+)\s*(.*?)(?:\[(\d+)\])?\s*;#{COMMENT}}) do |type, name, length, comment|
        packet.fields << Packet::Field.new(type.downcase, name.downcase.snake_case.to_sym, length || 1, comment.to_s.chomp)
      end
      @packets << packet
    end
  end

  def parse_enums
    # enum {
    #   TYPE_A,
    #   TYPE_B
    # }
    @content.scan(/^enum.*?\{(.*?)\}/m) do |body|
      body[0].split(/\n/).each do |line|
        line.scan(%r{([^_]+)_(\w+)\s*,?#{COMMENT}}) do |key, value, comment|
          (@enums[key] ||= []) << Enum.new(value, comment)
        end
      end
    end
  end

  def parse_bit_enums
    # #define TYPE_A 23
    # #define TYPE_B 24
    @content.scan(%r{^#define\s*([^_]+)_(\w+)\s*(\d+)#{COMMENT}}) do |key, name, value, comment|
      bit_enum = @bit_enums[key] ||= {}
      bit_enum[name] = BitEnum.new(value, comment)
    end
  end

  def to_s
    string = []
    # packets
    @packets.each do |packet|
      string << packet.inspect
    end
    # bit_enums
    @bit_enums.each do |name, enum|
      string << "bit[#{name}] = #{enum.inspect}"
    end
    # enums
    @enums.each do |name, enum|
      string << "enum[#{name}] = #{enum.inspect}"
    end

    string.join("\n")
  end

  class Packet < Struct.new(:type, :comment)
    def fields
      @fields ||= []
    end

    class Field < Struct.new(:type, :name, :length, :comment)
      def inspect
        n = name.inspect
        n += length != 1 ? ", :len => #{length}" : ""
        "%-10s %-30s # %s" % [ type, n, comment ]
      end

      def to_template
        $templates["field"].process(self)
      end
    end

    def inspect
      "Packet[#{type}] = # #{comment}#{fields.map {|f| f.inspect }.join("\n")}\n"
    end

    def to_template
      $templates["packet"].process(self)
    end
  end

  class Enum < Struct.new(:value, :comment)
    def inspect
      value
    end
  end

  class BitEnum < Enum
  end

end

class Template < Struct.new(:body)
  def process(object)
    eval(%{"#{body}"}, object.send(:binding))
  end
end

if $0 == __FILE__
  $templates = {}
  DATA.read.scan(/^%%(.*?)\n(.*?)%%\/.*?/m) do |key, body|
    $templates[key] = Template.new(body)
  end

  p = StructParser.new(ARGV[0])
  # packets
  p.packets.each do |packet|
    puts packet.to_template
  end
  # enums
  # bit_enums
end

__END__
%%packet
# #{comment}
define_packet :#{type.to_s.gsub(/^IS_/, '')} do
#{(fields.map {|f| "  #{f.to_template}" }.join("")).chomp}
end


%%/packet

%%field
#{inspect}
%%/field

%%enum
%%/enum

%%bitenum
%%/bitenum
