class Symbol
  # usage:
  # case packet
  # when :VER; ...
  # when :TINY_SMALL; ...
  # when :TINY; ...
  # end
  def ===(other)
    case other
    when LFS::Parser::Packet::Base
      other === self
    else
      super(other)
    end
  end

  def to_packet(options = {})
    case self.to_s
    when /^(TINY|SMALL)_(.*)/
      ::LFS::Parser::Packet.create($1.intern, options.merge(:subtype => $2.intern))
    else
      ::LFS::Parser::Packet.create(self, options)
    end
  end
end
