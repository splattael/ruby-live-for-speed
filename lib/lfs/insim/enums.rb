require 'enum.rb'

module LFS
  module Parser
    module Enum
      Penalty = ::Enum.new(
        :NONE,
        :DT,
        :DT_VALID,
        :SG,
        :SG_VALID,
        :P30,
        :P45,
        :NUM
      )
      PenaltyReason = ::Enum.new(
        :UNKNOWN,   # 0 - unknown or cleared penalty
        :ADMIN,     # 1 - penalty given by admin
        :WRONG_WAY,   # 2 - wrong way driving
        :FALSE_START, # 3 - starting before green light
        :SPEEDING,    # 4 - speeding in pit lane
        :STOP_SHORT,  # 5 - stop-go pit stop too short
        :STOP_LATE,   # 6 - compulsory stop is too late
        :NUM
      )
      PitlaneReason = ::Enum.new(
        :EXIT,   # 0 - left pit lane
        :ENTER,    # 1 - entered pit lane
        :NO_PURPOSE, # 2 - entered for no purpose
        :DT,     # 3 - entered for drive-through
        :SG,     # 4 - entered for stop-go
        :NUM
      )
      Pitwork = ::BitEnum.new(
        :NOTHING,    # bit 0 (1)
        :STOP,     # bit 1 (2)
        :FR_DAM,     # bit 2 (4)
        :FR_WHL,     # etc...
        :LE_FR_DAM,
        :LE_FR_WHL,
        :RI_FR_DAM,
        :RI_FR_WHL,
        :RE_DAM,
        :RE_WHL,
        :LE_RE_DAM,
        :LE_RE_WHL,
        :RI_RE_DAM,
        :RI_RE_WHL,
        :BODY_MINOR,
        :BODY_MAJOR,
        :SETUP,
        :REFUEL
      )
      Tyre = ::Enum.new(
        :R1,      # 0
        :R2,      # 1
        :R3,      # 2
        :R4,      # 3
        :ROAD_SUPER,  # 4
        :ROAD_NORMAL, # 5
        :HYBRID,    # 6
        :KNOBBLY,   # 7
        :NUM
      )
      PlayerFlags = ::BitEnum.new(
        :SWAPSIDE,
        :GC_CUT,
        :GC_BLIP,
        :AUTOGEARS,
        :SHIFTER,
        :RESERVED,
        :HELP_B,
        :AXIS_CLUTCH,
        :INPITS,
        :AUTOCLUTCH,
        :MOUSE,
        :KB_NO_HELP,
        :KB_STABILISED,
        :CUSTOM_VIEW
      )
      MsgType = ::Enum.new(
        :SYSTEM,     # 0 - system message
        :USER,     # 1 - normal visible user message
        :PREFIX,     # 2 - hidden message starting with special prefix (see ISI)
        :O,        # 3 - hidden message typed on local pc with /o command
        :NUM
      )
      Camera = ::Enum.new(
        :FOLLOW,  # 0 - arcade
        :HELI,    # 1 - helicopter
        :CAM,   # 2 - tv camera
        :DRIVER,  # 3 - cockpit
        :CUSTOM,  # 4 - custom
        :MAX
      )
      StateFlag = ::BitEnum.new(
        :GAME, #      1   // in game (or MPR)
        :REPLAY, #      2   // in SPR
        :PAUSED, #     4   // paused
        :SHIFTU, #      8   // SHIFT+U mode
        :SHIFTU_HIGH, #   16    // HIGH view
        :SHIFTU_FOLLOW,# 32    // following car
        :SHIFTU_NO_OPT,# 64    // SHIFT+U buttons hidden
        :SHOW_2D,#     128   // showing 2d display
        :FRONT_END,#   256   // entry screen
        :MULTI,#     512   // multiplayer mode
        :MPSPEEDUP,#   1024  // multiplayer speedup option
        :WINDOWED,#    2048  // LFS is running in a window
        :SOUND_MUTE,#    4096  // sound is switched off
        :VIEW_OVERRIDE,# 8192  // override user view
        :VISIBLE#     16384 // InSim buttons visible
      )
      RelayError = ::Enum.new(
        :NONE,
        :PACKET, #       1   // Invalid packet sent by client (wrong structure / length)
        :PACKET2, # 		2	// Invalid packet sent by client (packet was not allowed to be forwarded to host)
        :HOSTNAME, # 	3	// Wrong hostname given by client
        :ADMIN, # 		4	// Wrong admin pass given by client
        :SPEC # 		5	// Wrong spec pass given by client
      )
      PacketType = ::Enum.new(
        :NONE,   #  0         : not used
        :ISI,    #  1 - instruction   : insim initialise
        :VER,    #  2 - info      : version info
        :TINY,   #  3 - both ways   : multi purpose
        :SMALL,    #  4 - both ways   : multi purpose
        :STA,    #  5 - info      : state info
        :SCH,    #  6 - instruction   : single character
        :SFP,    #  7 - instruction   : state flags pack
        :SCC,    #  8 - instruction   : set car camera
        :CPP,    #  9 - both ways   : cam pos pack
        :ISM,    # 10 - info      : start multiplayer
        :MSO,    # 11 - info      : message out
        :III,    # 12 - info      : hidden /i message
        :MST,    # 13 - instruction   : type message or /command
        :MTC,    # 14 - instruction   : message to a connection
        :MOD,    # 15 - instruction   : set screen mode
        :VTN,    # 16 - info      : vote notification
        :RST,    # 17 - info      : race start
        :NCN,    # 18 - info      : new connection
        :CNL,    # 19 - info      : connection left
        :CPR,    # 20 - info      : connection renamed
        :NPL,    # 21 - info      : new player (joined race)
        :PLP,    # 22 - info      : player pit (keeps slot in race)
        :PLL,    # 23 - info      : player leave (spectate - loses slot)
        :LAP,    # 24 - info      : lap time
        :SPX,    # 25 - info      : split x time
        :PIT,    # 26 - info      : pit stop start
        :PSF,    # 27 - info      : pit stop finish
        :PLA,    # 28 - info      : pit lane enter / leave
        :CCH,    # 29 - info      : camera changed
        :PEN,    # 30 - info      : penalty given or cleared
        :TOC,    # 31 - info      : take over car
        :FLG,    # 32 - info      : flag (yellow or blue)
        :PFL,    # 33 - info      : player flags (help flags)
        :FIN,    # 34 - info      : finished race
        :RES,    # 35 - info      : result confirmed
        :REO,    # 36 - both ways   : reorder (info or instruction)
        :NLP,    # 37 - info      : node and lap packet
        :MCI,    # 38 - info      : multi car info
        :MSX,    # 39 - instruction   : type message
        :MSL,    # 40 - instruction   : message to local computer
        :CRS,    # 41 - info      : car reset
        :BFN,    # 42 - both ways   : delete buttons / receive button requests
        :SPARE_43,    # 43
        :SPARE_44,    # 44
        :BTN,    # 45 - instruction   : show a button on local or remote screen
        :BTC,    # 46 - info      : sent when a user clicks a button
        :BTT     # 47 - info      : sent after typing into a button
      ).
      # Test
      add(150, :TEST).
      add(151, :UNKN).
      # relay
      add(252,
        :HLR,    # 252 # Send : To request a hostlist
        :HOS,    # 253 # Receive : Hostlist info
        :SEL,    # 254 # Send : To select a host
        :ERR     # 255  # Receive : An error number
      )
    end # Enum

    Tiny = ::Enum.new(
      :NONE,		#  0					: see "maintaining the connection"
      :VER,		#  1 - info request	: get version
      :CLOSE,		#  2 - instruction		: close insim
      :PING,		#  3 - ping request	: external progam requesting a reply
      :REPLY,		#  4 - ping reply		: reply to a ping request
      :VTC,		#  5 - info			: vote cancelled
      :SCP,		#  6 - info request	: send camera pos
      :SST,		#  7 - info request	: send state info
      :GTH,		#  8 - info request	: get time in hundredths (i.e. SMALL_RTP)
      :MPE,		#  9 - info			: multi player end
      :ISM,		# 10 - info request	: get multiplayer info (i.e. ISP_ISM)
      :REN,		# 11 - info			: race end (return to game setup screen)
      :CLR,		# 12 - info			: all players cleared from race
      :NCN,		# 13 - info			: get all connections
      :NPL,		# 14 - info			: get all players
      :RES,		# 15 - info			: get all results
      :NLP,		# 16 - info request	: send an IS_NLP
      :MCI,		# 17 - info request	: send an IS_MCI
      :REO,		# 18 - info request	: send an IS_REO
      :RST,		# 19 - info request	: send an IS_RST
      :AXI,		# 20 - info request	: send an IS_AXI
      :AXC		# 21 - info			: autocross cleared
    )
  end
end
