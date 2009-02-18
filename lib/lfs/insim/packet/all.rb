module LFS
  module Parser
    module Packet

      #  // InSim Init - packet to initialise the InSim system
      define_packet :ISI, 44 do
        word       :udpport                       # Port for UDP replies from LFS (0 to 65535)
        word       :flags                         # Bit flags for options (see below)
        byte       spare
        byte       :prefix                        # Special host message prefix character
        word       :interval                      # Time in ms between NLP or MCI (0 = none)
        char       :admin, :length => 16          # Admin password (if set in LFS)
        char       :iname, :length => 16          # A short name for your program
      end


      #  // VERsion
      define_packet :VER, 20 do
        char       :version, :length => 8         # LFS version, e.g. 0.3G
        char       :product, :length => 6         # Product : DEMO or S1
        word       :insim_version                 # InSim Version : increased when InSim packets change
      end


      #  // STAte
      define_packet :STA, 28 do
        float      :replay_speed                  # 4-byte float - 1.0 is normal speed
        word       :flags                         # ISS state flags (see below)
        byte       :ingame_camera                 # Which type of camera is selected (see below)
        byte       :view_player_id                # Unique ID of viewed player (0 = none)
        byte       :players                       # Number of players in race
        byte       :conections                    # Number of connections including host
        byte       :finished                      # Number finished or qualified
        byte       :race_state                    # 0 - no race / 1 - race / 2 - qualifying
        byte       :qual_mins                     # 
        byte       :race_laps                     # see "RaceLaps" near the top of this document
        byte       spare
        byte       spare
        char       :track, :length => 6           # short name for track e.g. FE2R
        byte       :weather                       # 0,1,2...
        byte       :wind                          # 0=off 1=weak 2=strong
      end


      #  // State Flags Pack
      define_packet :SFP, 8 do
        word       :flag                          # the state to set
        byte       :enabled                       # 0 = off / 1 = on
        byte       spare
      end


      #  // MODe : send to LFS to change screen mode
      define_packet :MOD, 20 do
        int        :bits_16                       # set to choose 16-bit
        int        :refresh_rate                  # refresh rate - zero for default
        int        :width                         # 0 means go to window
        int        :height                        # 0 means go to window
      end


      #  // MSg Out - system messages and user messages 
      define_packet :MSO, 136 do
        byte       :connection_id                 # connection's unique id (0 = host)
        byte       :player_id                     # player's unique id (if zero, use UCID)
        byte       :usertype                      # set if typed by a user (see User Values below) 
        byte       :textstart                     # first character of the actual text (after player name)
        char       :msg, :length => 128           # 
      end


      #  // InsIm Info - /i message from user to host's InSim
      define_packet :III, 72 do
        byte       :connection_id                 # connection's unique id (0 = host)
        byte       :player_id                     # player's unique id (if zero, use UCID)
        byte       spare
        byte       spare
        char       :msg, :length => 64            # 
      end


      #  // MSg Type - send to LFS to type message or command
      define_packet :MST, 68 do
        char       :msg, :length => 64            # last byte must be zero
      end


      #  // MSg eXtended - like MST but longer (not for commands)
      define_packet :MSX, 100 do
        char       :msg, :length => 96            # last byte must be zero
      end


      #  // MSg Local - message to appear on local computer only
      define_packet :MSL, 132 do
        first_byte_is :sound

        char       :msg, :length => 128           # last byte must be zero
      end


      #  // Msg To Connection - hosts only - send to a connection or a player
      define_packet :MTC, 72 do
        byte       :connection_id                 # connection's unique id (0 = host)
        byte       :player_id                     # player's unique id (if zero, use UCID)
        byte       spare
        byte       spare
        char       :msg, :length => 64            # last byte must be zero
      end


      #  // Single CHaracter - send to simulate single character
      define_packet :SCH, 8 do
        byte       :key                           # key to press
        byte       :flags                         # bit 0 : SHIFT / bit 1 : CTRL
        byte       spare
        byte       spare
      end


      #  // InSim Multi
      define_packet :ISM, 40 do
        byte       :host                          # 0 = guest / 1 = host
        byte       spare
        byte       spare
        byte       spare
        char       :hostname, :length => 32       # the name of the host joined or started
      end


      #  // VoTe Notify
      define_packet :VTN, 8 do
        byte       :connection_id                 # connection's unique id
        byte       :action                        # VOTE_X (Vote Action as defined above)
        byte       spare
        byte       spare
      end


      #  // Race STart
      define_packet :RST, 28 do
        byte       :race_laps                     # 0 if qualifying
        byte       :qual_mins                     # 0 if race
        byte       :players                       # number of players in race
        byte       spare
        char       :track, :length => 6           # short track name
        byte       :weather                       # 
        byte       :wind                          # 
        word       :flags                         # race flags (must pit, can reset, etc - see below)
        word       :nodes                         # total number of nodes in the path
        word       :finish_node                   # node index - finish line

        array      :splits, :type => :word,       # split1, split2, split3
                            :initial_length => 3
      end


      #  // New ConN
      define_packet :NCN, 56 do
        first_byte_is :connection_id

        char       :username, :length => 24       # username
        char       :nickname, :length => 24       # nickname
        byte       :admin                         # 1 if admin
        byte       :connections                   # number of connections including host
        byte       :flags                         # bit 2 : remote
        byte       spare
      end


      #  // ConN Leave
      define_packet :CNL, 8 do
        first_byte_is :connection_id

        byte       :reason                        # leave reason (see below)
        byte       :connections                   # number of connections including host
        byte       spare
        byte       spare
      end


      #  // Conn Player Rename
      define_packet :CPR, 36 do
        first_byte_is :connection_id

        char       :nickname, :length => 24       # new nickname
        char       :plate, :length => 8           # number plate - NO ZERO AT END!
      end


      #  // New PLayer joining race (if PLID already exists, then leaving pits)
      define_packet :NPL, 76 do
        first_byte_is :player_id
        byte       :connection_id                 # connection's unique id
        byte       :ptype                         # bit 0 : female / bit 1 : AI / bit 2 : remote
        word       :flags                         # player flags
        char       :nickname, :length => 24       # nickname
        char       :plate, :length => 8           # number plate - NO ZERO AT END!
        char       :car, :length => 4             # car name
        char       :skin, :length => 16           # skin name - MAX_CAR_TEX_NAME
        tyres      :tyres
        byte       :h_mass                        # added mass (kg)
        byte       :h_tres                        # intake restriction
        byte       :model                         # driver model
        byte       :pass                          # passengers byte
        int        spare
        byte       spare
        byte       :players                       # number in race (same when leaving pits, 1 more if new)
        byte       spare
        byte       spare
      end


      #  // PLayer Pits (go to settings - stays in player list)
      define_packet :PLP, 4 do
        first_byte_is :player_id
      end


      #  // PLayer Leave race (spectate - removed from player list)
      define_packet :PLL, 4 do
        first_byte_is :player_id
      end


      #  // Car ReSet
      define_packet :CRS, 4 do
        first_byte_is :player_id
      end


      #  // LAP time
      define_packet :LAP, 20 do
        first_byte_is :player_id

        time       :lap_time                      # lap time (ms)
        time       :total_time                    # total time (ms)
        word       :laps_done                     # laps completed
        word       :flags                         # player flags
        byte       spare
        byte       :penalty                       # current penalty value (see below)
        byte       :stops                         # number of pit stops
        byte       spare
      end


      #  // SPlit X time
      define_packet :SPX, 16 do
        first_byte_is :player_id

        time       :split_time                    # split time (ms)
        time       :total_time                    # total time (ms)
        byte       :split                         # split number 1, 2, 3
        byte       :penalty                       # current penalty value (see below)
        byte       :stops                         # number of pit stops
        byte       spare
      end


      #  // PIT stop (stop at pit garage)
      define_packet :PIT, 24 do
        first_byte_is :player_id

        word       :laps_done                     # laps completed
        word       :flags                         # player flags
        byte       spare
        byte       :penalty                       # current penalty value (see below)
        byte       :stops                         # number of pit stops
        byte       spare
        tyres      :tyres
        unsigned   :pit_work                      # pit work
        unsigned   spare
      end


      #  // Pit Stop Finished
      define_packet :PSF, 12 do
        first_byte_is :player_id

        time       :stop_tim                     # stop time (ms)
        unsigned   spare
      end


      #  // Pit LAne
      define_packet :PLA, 8 do
        first_byte_is :player_id

        byte       :fact                          # pit lane fact (see below)
        byte       spare
        byte       spare
        byte       spare
      end


      #  // Camera CHange
      define_packet :CCH, 8 do
        first_byte_is :player_id

        byte       :camera                        # view identifier (see below)
        byte       spare
        byte       spare
        byte       spare
      end


      #  // PENalty (given or cleared)
      define_packet :PEN, 8 do
        first_byte_is :player_id

        byte       :old_penalty                   # old penalty value (see below)
        byte       :new_penalty                   # new penalty value (see below)
        byte       :reason                        # penalty reason (see below)
        byte       spare
      end


      #  // Take Over Car
      define_packet :TOC, 8 do
        first_byte_is :player_id

        byte       :old_connection_id             # old connection's unique id
        byte       :new_connection_id             # new connection's unique id
        byte       spare
        byte       spare
      end


      #  // FLaG (yellow or blue flag changed)
      define_packet :FLG, 8 do
        first_byte_is :player_id

        byte       :enabled                       # 0 = off / 1 = on
        byte       :flag                          # 1 = given blue / 2 = causing yellow
        byte       :car_behind_id                 # unique id of obstructed player
        byte       spare
      end


      #  // Player FLags (help flags changed)
      define_packet :PFL, 8 do
        first_byte_is :player_id

        word       :flags                         # player flags (see below)
        word       spare
      end


      #  // FINished race notification (not a final result - use IS_RES)
      define_packet :FIN, 20 do
        first_byte_is :player_id                  # player's unique id (0 = player left before result was sent)

        time       :total_time                    # race time (ms)
        time       :best_lap_time                 # best lap (ms)
        byte       spare
        byte       :stops                         # number of pit stops
        byte       :confirm                       # confirmation flags : disqualified etc - see below
        byte       spare
        word       :laps_done                     # laps completed
        word       :flags                         # player flags : help settings etc - see below
      end


      #  // RESult (qualify or confirmed finish)
      define_packet :RES, 84 do
        first_byte_is :player_id                  # player's unique id (0 = player left before result was sent)

        char       :username, :length => 24       # username
        char       :nickname, :length => 24       # nickname
        char       :plate, :length => 8           # number plate - NO ZERO AT END!
        char       :skin, :length => 4            # skin prefix
        time       :total_time                    # race time (ms)
        time       :best_lap_time                 # best lap (ms)
        byte       spare
        byte       :stops                         # number of pit stops
        byte       :confirm                       # confirmation flags : disqualified etc - see below
        byte       spare
        word       :laps_done                     # laps completed
        word       :flags                         # player flags : help settings etc - see below
        byte       :finish_position               # finish or qualify pos (0 = win / 255 = not added to table)
        byte       :results                       # total number of results (qualify doesn't always add a new one)
        word       :penalty_seconds               # penalty time in seconds (already included in race time)
      end


      #  // REOrder (when race restarts after qualifying)
      define_packet :REO, 36 do
        first_byte_is :players                    # number of players in race

        array      :player_ids, :type => :byte,   # all PLIDs in new order
                   :initial_length => 32
      end


      #  // AutoX Info
      define_packet :AXI, 40 do
        byte       :axstart                       # autocross start position
        byte       :checkpoints                   # number of checkpoints
        word       :object                        # number of objects
        char       :layout_name, :length => 32    # the name of the layout last loaded (if loaded locally)
      end


      #  // AutoX Object
      define_packet :AXO, 4 do
        first_byte_is :player_id
      end


      #  // Node and Lap Packet - variable size
      #  // 4 + NumP * 6 (PLUS 2 if needed to make it a multiple of 4)
      define_packet :NLP do   # TODO variable size
        first_byte_is :players                    # number of players in race

        array :nodes, :type => :node_lap,         # node and lap of each player, 1 to 32 of these (NumP)
              :read_unil => lambda { p index; true } # TODO

        def packet_size
          # TODO
          size = Header::SIZE + players * 6
          p "#{size}: size % 4 == 0 // #{players}"
          size += 2 unless size % 4 == 0
          p size
          size
        end
      end

      #  // Multi Car Info - if more than 8 in race then more than one of these is sent
      #  // 4 + NumP * 28
      define_packet :MCI do
        first_byte_is :number_comp_cars           # number of valid CompCar structs in this packet

        array :cars, :type => :comp_car, :initial_length => lambda { number_comp_cars }

        def packet_size
          number_comp_cars
        end
      end


      #  // Set Car Camera - Simplified camera packet (not SHIFT+U mode)
      define_packet :SCC, 8 do
        byte       :view_player_id                # UniqueID of player to view
        byte       :ingame_camera                 # InGameCam (as reported in StatePack)
        byte       spare
        byte       spare
      end


      #  // Cam Pos Pack - Full camera packet (in car OR SHIFT+U mode)
      define_packet :CPP, 32 do
        int_vec    :position                      # Position vector
        word       :h                             # heading - 0 points along Y axis
        word       :p                             # pitch   - 0 means looking at horizon
        word       :r                             # roll    - 0 means no roll
        byte       :view_player_id                # Unique ID of viewed player (0 = none)
        byte       :ingame_camera                 # InGameCam (as reported in StatePack)
        float      :fov                           # 4-byte float : FOV in degrees
        word       :time                          # Time to get there (0 means instant + reset)
        word       :flags                         # ISS state flags (see below)
      end


      #  // Button FunctioN - delete buttons / receive button requests
      define_packet :BFN, 8 do
        first_byte_is :subtype
        byte       :connection_id                 # connection to send to or from (0 = local / 255 = all)
        byte       :click_id                      # ID of button to delete (if SubT is BFN_DEL_BTN)
        byte       :inst                          # used internally by InSim
        byte       spare
      end


      #  // BuTtoN - button header - followed by 0 to 240 characters
      define_packet :BTN do
        first_byte_is :connection_id              # connection to display the button (0 = local / 255 = all)

        byte       :click_id                      # button ID (0 to 239)
        byte       :inst                          # some extra flags - see below
        byte       :style                         # button style flags - see below
        byte       :max_size                      # max chars to type in - see below
        byte       :l                             # left   : 0 - 200
        byte       :t                             # top    : 0 - 200
        byte       :w                             # width  : 0 - 200
        byte       :h                             # height : 0 - 200
        char       :text,
                   :read_length => lambda { header.packet_size - 12 } # TODO
      end


      #  // BuTton Click - sent back when user clicks a button
      define_packet :BTC, 8 do
        first_byte_is :connection_id              # connection to display the button (0 = local / 255 = all)

        byte       :click_id                      # button identifier originally sent in IS_BTN
        byte       :inst                          # used internally by InSim
        byte       :flags                         # button click flags - see below
        byte       spare
      end


      #  // BuTton Type - sent back when user types into a text entry button
      define_packet :BTT, 104 do
        first_byte_is :connection_id              # connection to display the button (0 = local / 255 = all)

        byte       :click_id                      # button identifier originally sent in IS_BTN
        byte       :inst                          # used internally by InSim
        byte       :max_size                      # from original button specification
        byte       spare
        char       :text, :length => 96           # typed text, zero to TypeIn specified in IS_BTN
      end

    end # Packet
  end # Parser
end # LFS

