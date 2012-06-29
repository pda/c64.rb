require "c64/bitfield"

module C64
  class AddressBus

    def initialize banks
      @ram = banks[:ram]
      @kernal = offset banks[:kernal], 0xE000
      @basic = offset banks[:basic], 0xA000
      @char = offset banks[:char], 0xD000
      @io = offset banks[:io], 0xD000

      @write_map = { charen: @ram }
      @read_map = { loram: @ram, hiram: @ram, charen: @char }
    end

    attr_reader :ram, :kernal, :basic, :char, :io

    def [] address
      case address.to_i

      when 0x0000
        # TODO: are reads from these addresses legal?
        0

      when 0x0001
        # TODO: are reads from these addresses legal?
        # raise "READ 0x%04X" % address
        0

      when 0xA000..0xBFFF
        @read_map[:loram][address]

      when 0xD000..0xDFFF
        @read_map[:charen][address]

      when 0xE000..0xFFFF
        @read_map[:hiram][address]

      else
        raise OutOfBounds if address > 0xFFFF
        ram[address]
      end
    end

    def []= address, value
      case address.to_i

      when 0x0000
        # data port direction flags.
        # TODO: something..
        # raise unless value == 0b101111

      when 0x0001
        # data port values.
        update_maps value

      when 0xD000..0xDFFF
        # I/O or character generator.
        @write_map[:charen][address] = value

      else
        ram[address] = value

      end
    end

    private

    def update_maps value
      value = ::C64::Bitfield.new(:loram, :hiram, :charen).new(value)
      @read_map[:loram] = value.loram? ? @basic : @ram
      @read_map[:hiram] = value.hiram? ? @kernal : @ram
      @read_map[:charen] = value.charen? ? @io : @char
      @write_map[:charen] = value.charen? ? @io : @ram
    end

    def offset(data, offset)
      OffsetAccess.new(data, offset)
    end

    class OffsetAccess
      def initialize(data, offset)
        @data = data
        @offset = offset
      end
      def [] address
        @data[address - @offset]
      end
      def []= address, value
        @data[address - @offset] = value
      end
    end

    Error = Class.new(StandardError)
    OutOfBounds = Class.new(Error)

  end
end
