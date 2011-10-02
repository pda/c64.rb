module C64

  # abstract integer, unknown length.
  class Uint

    def initialize value
      update value
    end

    def update value
      @value = value % modulus
    end

    def to_i
      @value
    end

    def == other
      to_i == other
    end

    def + other
      @value = (@value + other) % modulus
      self
    end

    def - other
      @value = (@value - other) % modulus
      self
    end

  end

  # unsigned 8-bit integer.
  class Uint8 < Uint
    def modulus; 0x100 end
    def bytes; [ @value ] end
  end

  # unsigned 16-bit integer, little-endian.
  class Uint16 < Uint
    def modulus; 0x10000 end
    def bytes; [ low, high ] end
    def high; @value >> 8 end
    def low; @value & 0xFF end

    def high= byte
      @value = (@value & 0x00FF) | byte << 8
    end

    def low= byte
      @value = (@value & 0xFF00) | byte
    end
  end

end
