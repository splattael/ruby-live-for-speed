class Symbol
  def ===(o)
    super(o) || o === self
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
