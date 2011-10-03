module C64
  class Memory

    def initialize size = 0x10000, options = {}
      @size = size
      path = options[:image] || "/dev/zero"
      @bytes = open(path) { |f| f.read @size }
    end

    attr_accessor :size

    def [] index
      i = index.to_i
      check_bounds i
      @bytes[i].unpack("C").first
    end

    def []= index, value
      i = index.to_i
      check_bounds i
      @bytes[i] = [value.to_i].pack("C")
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
