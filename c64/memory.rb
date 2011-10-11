module C64
  class Memory

    def initialize size = 0x10000, options = {}
      @size = size
      path = options[:image] || "/dev/zero"
      @bytes = open(path) { |f| f.read @size }
      @tag = options[:tag]
    end

    attr_accessor :size

    def [] index
      i = index.to_i
      check_bounds i
      value = @bytes[i].unpack("C").first
      puts "#{@tag}[%04X] >> %02X" % [i, value] if @tag && ENV["VERBOSE"] && ENV["VERBOSE"].include?("m")
      value
    end

    def []= index, value
      i = index.to_i
      check_bounds i
      @bytes[i] = [value.to_i].pack("C")
      puts "#{@tag}[%04X] << %02X" % [i, value] if @tag && ENV["VERBOSE"] && ENV["VERBOSE"].include?("m")
    end

    def inspect
      "#<#{self.class.name} @size=#{size} @tag=#{@tag}>"
    end

    private

    attr_accessor :bytes

    def check_bounds index
      if index < 0 || index >= size
        raise "Memory out of bounds: 0x%02X" % index
      end
    end

  end
end
