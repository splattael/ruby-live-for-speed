module LFS
  module Parser
    module Packet


      define_packet :MCI do
        array :cars, :type => :comp_car, :initial_length => lambda { valid_cars }

        def valid_cars
          first_byte
        end
      end
    end
  end
end
