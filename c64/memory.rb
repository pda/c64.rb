module C64
  class Memory

    def initialize
      @size = 0x10000
      @bytes = Array.new size, 0
    end

    attr_accessor :size

    def [] index
      check_bounds index
      @bytes[index]
    end

    def []= index, value
      check_bounds index
      @bytes[index] = value
    end

    def inspect
      "#<#{self.class.name} @size=#{size}>"
    end

    private

    def check_bounds index
      if index < 0 || index >= size
        raise "Memory out of bounds: 0x%02X" % index
      end
    end

  end
end
