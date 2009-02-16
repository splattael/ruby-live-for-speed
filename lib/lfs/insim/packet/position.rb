module LFS
  module Parser
    module Packet

      class CompCar < ::BinData::MultiValue
        include Helper

        word :node
        word :lap
        byte :player_id
        byte :position
        byte :info
        byte spare
        int  :x
        int  :y
        int  :z
        word :speed
        word :direction
        word :heading
        short :angle_vel
      end

      define_packet :MCI do
        array :cars, :type => :comp_car, :initial_length => lambda { valid_cars }

        def valid_cars
          first_byte
        end
      end
    end
  end
end
