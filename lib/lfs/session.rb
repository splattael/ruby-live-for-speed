# vim: set ts=2 sw=2 et:

require 'socket'

module LFS
  class Session
    class BreakLoop < StandardError; end

    attr_reader :socket, :version, :packet_factory

    def initialize(host, port, options={})
      @now = nil
      begin
        @socket = ::BinData::IO.new(TCPSocket.new(host, port))
        #@socket = TCPSocket.new(host, port)
      rescue => e
        raise "Could not connect to #{host}:#{port}: #{e}"
      end
      @connected = false
      @version = nil
      @options = options
      @packet_factory = ::LFS::Parser::Packet::Factory.new
      yield(self) if block_given?
    end

    def self.connect(options={}, &block)
      hostname, port = options.delete(:hostname), options.delete(:port)
      new(hostname, port, options).connect(options, &block)
    end

    def connect(options={}, &block)
      start(options, &block)
    ensure
      stop
      self
    end

    def self.local(address, options={})
      address(address, options)
    end

    def self.host(address, options={})
      address(address, options.update(:host => true))
    end

    def self.solaris(options={})
      new("192.168.0.2", 3000, options)
    end

    def self.address(address, options={})
      host, ip = address.to_s.split(/:/)
      ip = "3000" unless ip
      new(host, ip.to_i, options)
    end

    def start(options = {}, &block)
      options = { :version => true, :program_name => "lfs_insim" }.update(options)
      send :ISI, options
      yield(self) if block_given?
      self
    end

    def connected?
      @connected == true
    end

    def close
      if @connected
        send(:TINY_CLOSE)
        @connected = false
        @socket.close if @socket
      end
    end

    alias :stop :close

    def send(packet_type, options = {})
      packet = packet_type.to_packet(options)
      puts "<<< #{packet.inspect}" if $DEBUG
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

    def log(*msg)
      $stderr.puts "[%s] %s" % [ Time.now.strftime("%Y-%m-%dT%T"), msg.join(' ') ]
    end
  end

  class RelayedSession < Session
    RELAY_HOST = "isrelay.lfs.net"
    RELAY_PORT = 47474

    def initialize(host=RELAY_HOST, port=RELAY_PORT, &block)
      super(host, port)
    end

    def self.connect(options={}, &block)
      new.connect(options, &block)
    end

    def connect(options={}, &block)
      send(:SEL, options)
      yield(self) if block_given?
    ensure
      close
    end

    def self.hostlist
      hosts = []
      new do |session|
        session.send(:HLR)
        session.send(:HLR, :request => 23)
        loop do
          packet = session.parse_packet
          # p packet
          break if packet.request == 23
          hosts << packet.host_infos.map {|i| i }
        end
      end
      hosts.flatten.compact
    ensure
    end
  end
end
