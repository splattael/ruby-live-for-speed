module LFS
  module Parser
    module Packet
      define_packet :NCN, 56 do
        char :username, :length => 24
        char :nickname, :length => 24

        byte :admin
        byte :connections
        byte :flags
        byte spare
      end

      define_packet :CNL, 8 do
        byte :reason
        byte :connections
        byte spare
        byte spare
      end

      define_packet :NPL, 76 do
        byte :connection_id
        byte :player_type
        word :flags

        char :nickname,   :length => 24
        char :plate,      :length => 8

        char :car,        :length => 4
        char :skin_name,  :length => 16
        tyres :tyres

        byte :hc_mass
        byte :hc_ires
        byte :driver_model
        byte :passenger

        int  spare

        byte spare
        byte :in_race
        byte spare
        byte spare
      end

      define_packet :PLP, 4 do
      end

      define_packet :PLL, 4 do
      end
    end
  end
end
