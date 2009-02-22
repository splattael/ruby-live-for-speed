#!/usr/bin/ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")

require 'lfs'
require 'lfs/application'

config do |c|
  c.hostname = "78.111.71.32"
  c.port = 29978
  c.admin = "benuto"
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


