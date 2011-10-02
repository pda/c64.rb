module C64

  # abstract integer, unknown length.
  class Uint

    include Comparable

    def initialize value
      update value
    end

    def update value
      @value = value.to_i % modulus
    end

    def to_i
      @value
    end

    def <=> other
      @value <=> (other % modulus)
    end

    def zero?
      @value == 0
    end

    def + other
      copy @value + other.to_i
    end

    def - other
      copy @value - other.to_i
    end

    def >> bits
      copy @value >> bits
    end

    def << bits
      copy @value << bits
    end

    def & other
      copy @value & other.to_i
    end

    def inspect
      "#<%s(%d)>" % [ self.class.name, @value ]
    end

    private

    def copy value
      self.class.new value
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
