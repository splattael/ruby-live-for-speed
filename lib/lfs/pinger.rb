module LFS

  class Pinger
    def initialize(session)
      @session = session
      @pings = []
      @thread = nil
    end

    def started?
      !@thread.nil?
    end

    def start(every = 30.0)
      return if started?

      Thread.abort_on_exception = true
      @thread = Thread.new do
        loop do
          @session.log "Pinging"
          ping
          sleep every
        end
      end
      log "Starting #{self.class}"
    end

    def stop
      if @thread
        @thread.terminate
        @thread = nil
      end
    end

    def dead?
      @pings.size > 3
    end

    def ping
      @pings << Time.now
      if dead?
        log "Session might be dead?"
      end
      @session.send(:TINY_PING)
    end

    def log(*msg)
      @session.log(*msg)
    end

    def handle(packet)
      if packet === :TINY_REPLY
        if pinged_at = @pings.shift
          diff = Time.now - pinged_at
          log "Pong in %.4f" % diff
        else
          warn "Got REPLY but no PING sent"
        end
      end
    end
  end

end
