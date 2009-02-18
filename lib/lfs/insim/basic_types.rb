module LFS
  module Parser
    # Mimic types defined in LFS InSim.txt
    module Type
      # Char type. Variable length, value w/o null byte padding
      class Char < ::BinData::SingleValue
        string :char, :trim_value => true, :length => :length

        bindata_mandatory_parameter :length

        def length; @params[:length] end

        def get; self.char end
        def set(v); self.char = v end
      end

      # Byte type
      class Byte < ::BinData::SingleValue
        endian :little
        uint8 :byte

        def get; self.byte end
        def set(v); self.byte = v end
      end

      # Word type
      class Word < ::BinData::SingleValue
        endian :little
        uint16 :word

        def get; self.word end
        def set(v); self.word = v end
      end

      # Short type
      class Short < ::BinData::SingleValue
        endian :little
        int16 :short

        def get; self.short end
        def set(v); self.short = v end
      end
    
      # Unsigned type
      class Unsigned < ::BinData::SingleValue
        endian :little
        uint32 :unsigned, :length => 1

        def get; self.unsigned end
        def set(v); self.unsigned = v end
      end

      # Int type
      class Int < ::BinData::SingleValue
        endian :little
        int32 :int, :length => 1

        def get; self.int end
        def set(v); self.int = v end
      end

      # Float
      class Float < ::BinData::SingleValue
        float_le :float, :length => 1

        def get; self.float end
        def set(v); self.float = v end
      end

      # Float Vector
      class FloatVec < ::BinData::MultiValue
        float :x
        float :y
        float :z
      end

      # Int Vector
      class IntVec < ::BinData::MultiValue
        int :x
        int :y
        int :z
      end
    end
  end
end
