# Represents a C# style enumeration of known values.
#
# Usage:
#   Color = Enum.new(:Red, :Green, :Blue)
#   Color.is_a?(Enum) # => true
#   Color::Red.inspect # => "Color::Red" 
#   Color::Green.is_a?(Color) # => true
#   Color::Green.is_a?(Enum::Member) # => true
#   Color::Green.index # => 1
#   Color::Blue.enum # => Color
#   values = [[255, 0, 0], [0, 255, 0], [0, 0, 255]]
#   values[Color::Green] # => [0, 255, 0]
#   Color[0] # => Color::Red
#   Color.size # => 3
#
# Enums are enumerable. Enum::Members are comparable.
class Enum < Module
  class Member < Module
    attr_reader :enum, :index, :symbol

    def initialize(enum, index, symbol)
      @enum, @index, @symbol = enum, index, symbol
      # Allow Color::Red.is_a?(Color)
      extend enum
    end

    # Allow use of enum members as array indices
    alias :to_int :index
    alias :to_i :index

    # Allow comparison by index
    def <=>(other)
      @index <=> other.index
    end

    def ===(index_or_symbol)
      index_or_symbol == case index_or_symbol
      when Enum: self
      when Numeric: index
      when Symbol:  symbol
      else
        raise ArgumentError, "#{index_or_symbol.class} not supported"
      end

    end

    include Comparable
  end

  def initialize(*symbols, &block)
    @members = []
    add(0, *symbols)
    super(&block)
  end

  def add(start_index, *symbols)
    symbols.each_with_index do |symbol, index|
      index = start_index + index_modifier(index)
      # Allow Enum.new(:foo)
      symbol = symbol.to_s.sub(/^[a-z]/) { |letter| letter.upcase }.to_sym
      member = Enum::Member.new(self, index, symbol)
      const_set(symbol, member)
      @members << member
    end
    self
  end

  def [](index_or_symbol)
    case index_or_symbol
    when Enum: index_or_symbol
    when Numeric: @members.detect {|m| m.index == index_or_symbol }
    when Symbol:  @members.detect {|m| m.symbol == index_or_symbol }
    else
      raise ArgumentError, "#{index_or_symbol.class} not supported"
    end
  end
  def values(index) @members.select {|m| m.index == index } end
  def size() @members.size end
  alias :length :size

  def first(*args) @members.first(*args) end
  def last(*args) @members.last(*args) end

  def each(&block) @members.each(&block) end
  include Enumerable

  protected
    def index_modifier(index)
      index
    end
end

class BitEnum < Enum
  class ::Enum::Member < Module
    def |(other)
      index | (other ? other.index : 0)
    end
  end

  def index_modifier(index)
    2 ** index
  end

  def values(index) @members.select {|m| m.index & index == m.index } end

  def |(*members)
    members.flatten.compact.inject(0) {|sum, member| sum |= member.index }
  end

  def empty
    @empty ||= Enum::Member.new(self, 0, :NONE)
  end
end
