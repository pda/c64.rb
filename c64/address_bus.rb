require "c64/bitfield"

module C64
  class AddressBus

    def initialize banks
      @ram = banks[:ram]
      @kernal = banks[:kernal]
      @basic = banks[:basic]
      @char = banks[:char]
      @io = banks[:io]

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
        @read_map[:loram][address - 0xA000]

      when 0xD000..0xDFFF
        @read_map[:charen][address - 0xD000]

      when 0xE000..0xFFFF
        @read_map[:hiram][address - 0xE000]

      else
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
        @write_map[:charen][address - 0xD000] = value

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

  end
end
