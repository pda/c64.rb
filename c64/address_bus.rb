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
      case address

      when 0x0000..0x0001
        raise "READ 0x%04X" % address

      when 0xA000..0xAFFF
        @read_map[:loram][address - 0xA000]

      when 0xD000..0xDFFF
        @read_map[:charen][address - 0xD000]

      when 0xE000..0xEFFF
        @read_map[:hiram][address - 0xE000]

      else
        ram[address]
      end
    end

    def []= address, value
      case address

      when 0x0000
        raise "WRITE 0x%02X => 0x%04X" % [ value, address ]

      when 0x0001
        update_maps value

      when 0xD000..0xDFFF
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
