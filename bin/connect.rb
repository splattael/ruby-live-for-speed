#!/usr/bin/ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")

require 'lfs'

# relay

if ARGV.empty?
  LFS::RelayedSession.hostlist.sort do |a, b|
    result = b.connections <=> a.connections
    result = a.hostname <=> b.hostname if result.zero?
    result
  end.each do |host|
    puts "#{host.hostname} #{host.connections}"
  end

  exit
end

class Pinger
  def initialize(session, calc_roundtrip=false)
    @pings = []
    @session = session
    @calc_roundtrip = calc_roundtrip
  end

  def start(every = 20.0)
    Thread.new do
      sleep 5
      loop do
        @session.log "pinging"
        ping
        sleep every
      end
    end
  end
  
  def dead?
    @calc_roundtrip ? @pings.size > 3 : false
  end

  def ping
    @pings << Time.now if @calc_roundtrip
    @session.send_tiny :PING
  end

  def handle_packet(packet)
    if packet.typed?(:TINY) && packet.subtype == :REPLY
      if @calc_roundtrip
        if pinged_at = @pings.shift
          diff = Time.now - pinged_at
          @session.log "pong in %.4f" % diff
        else
          warn "got REPLY but no PING sent"
        end
      end
    end
  end
end

LFS::Parser::Packet.unregister

LFS::RelayedSession.connect(ARGV.first) do |session|
  pinger = Pinger.new(session)
  pinger.start

  started = Time.now.to_f
  packets = 1
  prev = nil
  session.parse do |packet|
    pinger.handle_packet(packet)

    diff = Time.now.to_f - started
    print "\b" * prev.size if prev
    prev = "%-5d %.4f p/s" % [ packets, packets / diff ]
    $stdout.print prev
    $stdout.flush
    packets += 1
    
    case packet.packet_type
    when :UNKN
      # warn "UNKN: ##{packet.header.packet_type}"
    end
  end
end


