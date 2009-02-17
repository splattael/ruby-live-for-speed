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

LFS::Parser::Packet.unregister

options = ARGV[1..-1].inject({}) do |hash, option|
  key, value = option.split(/=/)
  hash[key.intern] = value
  hash
end

session_provider, args = if ARGV.first =~ /(\d+\.\d+\.\d+\.\d+):(\d+)/
  [ LFS::Session, { :hostname => $1, :port => $2.to_i } ]
else
  [ LFS::RelayedSession, { :hostname => ARGV.first } ]
end

session_provider.connect(args.merge(options)) do |session|
  pinger = LFS::Pinger.new(session)

  started = Time.now.to_f
  packet_count = 0
  packet_size = 0
  prev = nil
  session.parse do |packet|
    pinger.handle(packet)

    diff = Time.now.to_f - started
    $stdout.print "\b" * prev.size if prev
    prev = "%-5d %.2f p/s (%.2f kB/s) %.2f cpu/p" %
      [ packet_count, packet_count / diff, packet_size / diff / 1024,
        Process.times.utime / packet_count ]
    $stdout.print prev
    $stdout.flush
    packet_count += 1
    packet_size += packet.packet_size

    case packet
    when :VER
      puts "VERSION: #{packet.product} #{packet.version} ##{packet.insim_version}"
      pinger.start
    when :TINY, :SMALL
      # p packet.subtype
    when :MCI
      # p packet
    when :UNKN
      warn "UNKN: #{::LFS::Parser::Enum::PacketType[packet.header.packet_type].symbol} (##{packet.header.packet_type})"
    end
  end
end
