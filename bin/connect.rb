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

LFS::RelayedSession.connect(ARGV.first) do |session|
  started = Time.now.to_f
  packets = 1
  prev = nil
  session.parse do |packet|
    diff = Time.now.to_f - started
    print "\b" * prev.size if prev
    prev = "%d %.4f p/s" % [ packets, packets / diff ]
    print prev
    STDOUT.flush
    packets += 1

    case packet.packet_type
    when :LAP, :SPX: p packet
    end
  end
end


