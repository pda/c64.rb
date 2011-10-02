module C64
  class Memory

    def initialize
      @size = 0x10000
      @bytes = open("/dev/zero") { |f| f.read @size }
    end

    attr_accessor :size

    def [] index
      check_bounds index
      @bytes[index].unpack("C").first
    end

    def []= index, value
      check_bounds index
      @bytes[index] = [value].pack("C")
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
