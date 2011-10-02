module C64
  class MemoryOverlay

    def initialize base, local, offset
      @base = base
      @local = local
      @offset = offset
      @size = local.size
    end

    def [] address
      if local? address
        @local[localize(address)]
      else
        @base[address]
      end
    end

    def []= address, value
      if local? address
        @local[localize(address)] = value
      else
        @base[address] = value
      end
    end

    private

    attr_reader :base, :local, :offset, :size

    def localize address
      address - offset
    end

    def local? address
      address >= offset && localize(address) < size
    end

  end
end
