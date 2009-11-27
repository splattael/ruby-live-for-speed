module LFS
  module Parser
    module Types
      # Complex
      class Time < ::BinData::Record
        unsigned :milliseconds

        def get; self.milliseconds end
        def set(v); self.milliseconds = v end

        def to_s
          human_time(milliseconds)
        end
        alias :inspect :to_s

        private

        def human_time(time)
          # TODO refactor
          return "" unless time

          times = []
          times << [ "%03d",  time % 1000 ] # milli
          time /= 1000
          times << [ "%02d.", time % 60 ]   # seconds
          time /= 60
          times << [ "%02d:", time % 60 ]   # minutes
          time /= 60
          times << [ "%02d:", time ] if time > 0 # bigger than an hour?

          times.map {|format, digit| format % digit }.reverse.join("")
        end

        class Tyres < ::BinData::Record
          byte :rear_left
          byte :rear_right
          byte :front_left
          byte :front_right
        end
      end # Time

      #  // Car info in 28 bytes - there is an array of these in the MCI (below)
      class CompCar < ::BinData::Record
        include ::LFS::Parser::Packet::Helper

        word       :node                          # current path node
        word       :lap                           # current lap
        byte       :plid                          # player's unique id
        byte       :position                      # current race position : 0 = unknown, 1 = leader, etc...
        byte       :info                          # flags and other info - see below
        byte       spare                          # 
        int        :x                             # X map (65536 = 1 metre)
        int        :y                             # Y map (65536 = 1 metre)
        int        :z                             # Z alt (65536 = 1 metre)
        word       :speed                         # speed (32768 = 100 m/s)
        word       :direction                     # direction of car's motion : 0 = world y direction, 32768 = 180 deg
        word       :heading                       # direction of forward axis : 0 = world y direction, 32768 = 180 deg
        short      :angvel                        # signed, rate of change of heading : (16384 = 360 deg/s)
      end


      #  // Car info in 6 bytes - there is an array of these in the NLP (below)
      class NodeLap < ::BinData::Record
        include ::LFS::Parser::Packet::Helper

        word       :node                          # current path node
        word       :lap                           # current lap
        byte       :plid                          # player's unique id
        byte       :position                      # current race position : 0 = unknown, 1 = leader, etc...
      end

      #
      class OutSimPack < ::BinData::Record
        include ::LFS::Parser::Packet::Helper

        time       :time                          # time in milliseconds (to check order)
        float_vec  :angvel                        # 3 floats, angular velocity vector
        float      :heading                       # anticlockwise from above (Z)
        float      :pitch                         # anticlockwise from right (X)
        float      :roll                          # anticlockwise from front (Y)
        float_vec  :accel                         # 3 floats X, Y, Z
        float_vec  :vel                           # 3 floats X, Y, Z
        int_vec    :pos                           # 3 ints   X, Y, Z (1m = 65536)
        int        :out_sim_id                    # optional - only if OutSim ID is specified
      end


      # 
      class OutGaugePack < ::BinData::Record
        include ::LFS::Parser::Packet::Helper

        time       :time                          # time in milliseconds (to check order)
        char       :car, :len => 4                # Car name
        word       :flags                         # OG_FLAGS (see below)
        byte       :gear                          # Reverse:0, Neutral:1, First:2...
        byte       spare
        float      :speed                         # M/S
        float      :rpm                           # RPM
        float      :turbo                         # BAR
        float      :engtemp                       # C
        float      :fuel                          # 0 to 1
        float      :oilpress                      # BAR
        float      spare
        float      spare
        float      spare
        float      :throttle                      # 0 to 1
        float      :brake                         # 0 to 1
        float      :clutch                        # 0 to 1
        char       :display1, :len => 16       # Usually Fuel
        char       :display2, :len => 16       # Usually Settings
        int        :out_gauge_id                  # optional - only if OutGauge ID is specified
      end

    end
  end
end
