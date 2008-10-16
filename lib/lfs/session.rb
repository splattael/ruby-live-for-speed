# vim: set ts=2 sw=2 et:

require 'socket'

module LFS
  class Session
    class BreakLoop < StandardError; end

    attr_reader :socket, :version, :packet_factory

    def initialize(host, port)
      @now = nil
      begin
        @socket = TCPSocket.new(host, port)
      rescue => e
        raise "Could not connect to #{host}:#{port}: #{e}"
      end
      @connected = false
      @version = nil
      @packet_factory = ::LFS::Parser::Packet::Factory.new
      yield(self) if block_given?
    end

    def self.connect(args={}, &block)
      hostname, port = args.delete(:hostname), args.delete(:port)
      new(hostname, port, args).connect(args, &block)
    end

    def connect(args={}, &block)
      start(args, &block)
    ensure
      stop
      self
    end

    def self.local(address, args={})
      address(address, args)
    end

    def self.host(address, args={})
      address(address, args.update(:host => true))
    end

    def self.solaris(args={})
      new("192.168.0.2", 3000, args)
    end

    def self.address(address, args={})
      host, ip = address.to_s.split(/:/)
      ip = "3000" unless ip
      new(host, ip.to_i, args)
    end

    def start(args = {}, &block)
      args = { :version => true, :progname => "lfs_insim" }.update(@options).update(args)
      send :ISI, args
      yield(self) if block_given?
      self
    end

    def connected?
      @connected == true
    end

    def close
      @connected = false
      @socket.close if @socket
    end

    alias :stop :close

    def send(packet_type, args={})
      packet = ::LFS::Parser::Packet.create(packet_type, args)
      puts "<<< #{packet.inspect}"
      packet.write(@socket)
    end

    def break_loop
      throw :break
    end

    def descriptor
      @socket
    end

    def parse_packet
      @packet_factory.read(@socket)
    end

    def parse(&block)
      loop do
        packet = parse_packet
        break_loop unless packet
        yield(packet) if block_given?
      end
    end

    def now
      @now || (Time.now.to_f * 1000).to_i
    end

    def log(*args)
      $stderr.puts "[%s] %s" % [ Time.now.strftime("%Y-%m-%dT%T"), args.join(' ') ]
    end
  end

  class RelayedSession < Session
    RELAY_HOST = "isrelay.lfs.net"
    RELAY_PORT = 47474

    def initialize(host=RELAY_HOST, port=RELAY_PORT, &block)
      super(host, port)
    end

    def self.connect(hostname, &block)
      new.connect(hostname, &block)
    end

    def connect(hostname, &block)
      send(:SEL, :hostname => hostname)
      yield(self) if block_given?
    ensure
      close
    end

    def self.hostlist
      hosts = []
      new do |session|
        session.send(:HLR)
        loop do
          packet = session.parse_packet
          # p packet
          break if packet.nil? || !packet.typed?(:HOS) || packet.host_infos.size != 6
          hosts << packet.host_infos.map {|i| i }
        end
      end
      hosts.flatten.compact
    ensure
    end
  end
end
