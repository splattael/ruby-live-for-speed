#!/usr/bin/ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")

require 'lfs'
require 'lfs/application'

raise "usage: #{$0} hostname port admin-password" unless ARGV.size == 3

config do |c|
  c.hostname = ARGV.shift
  c.port = ARGV.shift.to_i
  c.admin = ARGV.shift
end

on :TINY do |context|
  case context.packet
  when :TINY_NONE
    puts "ponging"
    send(:TINY_PING)
  end
end

on :STA do |context|
  packet = context.packet
  p packet.track
end

on :VER do |context|
  packet = context.packet
  p "Version #{packet.product} #{packet.version}"
end


