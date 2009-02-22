module LFS

  def self.app
    @app ||= Application.new
  end
  
  Config = Struct.new(:hostname, :port, :admin, :spec_password)

  class Application

    def initialize
      @events = Hash.new {|k,v| k[v] = []}
    end

    def start
      on :VER do |packet|
        status
      end
      connect
    end

    def connect
      hash = @config.members.inject({}) do |hash, member|
        hash[member] = @config[member]
        hash
      end
      LFS::Session.connect(hash) do |session|
        @queue = Queue.new(session)
        session.parse do |packet|
          p packet
          events = events_for(packet.packet_type, nil)
          events.each do |event|
            @queue << event.invoke(:packet => packet)
          end
        end
      end
    end

    def config(&block)
      @config = Config.new
      block.call(@config)
      @config
    end

    def on(type, match=nil, &block)
      @events[type] << e = Event.new(match, block)
      e
    end
 
    def events_for(type, matcher)
      @events[type].select do |e|
        # TODO matcher
        e
      end
    end

  end # Application

  class Queue #:nodoc:
    def initialize(session)
      @session = session
    end
 
    def <<(packets)
      Array(packets).each do |packet|
        @session.send(packet) if packet
      end
    end
  end

  class Event #:nodoc:
    attr_accessor :match, :block
    def initialize(match, block)
      @match = match
      @block = block
    end
 
    # Execute event in the context of EventContext.
    def invoke(params={})
      match = params[:message].match(@match) if @match && params[:message]
      params.merge!(:match => match)
 
      context = EventContext.new(params)
      context.instance_eval(&@block)
      context.commands
    end

  end
 
  class EventContext
    attr_accessor :commands, :packet

    def initialize(args = {})
      args.each {|k,v| instance_variable_set("@#{k}",v)}
      @commands = []
    end

    def send(packet, options={})
      @commands << packet.to_packet(options)
    end

    def status
      send(:TINY_ISM)
      send(:TINY_SST)
      send(:TINY_NCN)
      send(:TINY_NPL)
      send(:TINY_RES)
    end

  end

end

# Assign methods to current Isaac instance
%w(config helpers on).each do |method|
  eval(<<-EOF)
    def #{method}(*args, &block)
      LFS.app.#{method}(*args, &block)
    end
  EOF
end
 
# Clever, thanks Sinatra.
at_exit do
  raise $! if $!
  LFS.app.start
end
