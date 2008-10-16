module LFS
  module Parser
    module Types
      # Complex
      class Time < ::BinData::SingleValue
        unsigned :milliseconds

        def get; self.milliseconds end
        def set(v); self.milliseconds = v end

        def to_s
          human_time(milliseconds)
        end
        alias :inspect :to_s

        private
        def human_time(time, show_sign=false)
          return "-" unless time

          sign = "-" if time < 0
          sign = "+" if time > 0 && show_sign
          time = time.abs
          if (time / 1000) / 60 > 59 then
            "#{sign}%02d:%02d:%02d.%03d" % [ (time / 1000) / 60 / 60, (time / 1000) / 60 % 60, (time / 1000) % 60, time % 1000 ]
          else
            "#{sign}%02d:%02d.%03d" % [ (time / 1000) / 60, (time / 1000) % 60, time % 1000 ]
          end
        end
      end
    end
  end
end
