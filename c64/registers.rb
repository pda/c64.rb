require "c64/data_types"
require "c64/bitfield"

module C64
  class Registers

    def initialize pc = 0, ac = 0, x = 0, y = 0, sr = 0, sp = 0
      @values = {
        pc: Uint16.new(pc),
        ac: Uint8.new(ac),
        x: Uint8.new(x),
        y: Uint8.new(y),
        sp: Uint8.new(sp),
        sr: Uint8.new(sr),
      }
    end

    # register readers
    def pc; self[:pc] end
    def ac; self[:ac] end
    def x; self[:x] end
    def y; self[:y] end
    def sp; self[:sp] end
    def sr; self[:sr] end

    # register writers
    def pc= value; self[:pc] = value end
    def ac= value; self[:ac] = value end
    def x= value; self[:x] = value end
    def y= value; self[:y] = value end
    def sp= value; self[:sp] = value end
    def sr= value; self[:sr] = value end

    # array-access reader
    def [] register
      @values[register]
    end

    # array-access writer
    def []= register, value
      @values[register].update value
    end

    class Status < ::C64::Bitfield.new(
      :carry, :zero, :interrupt, :decimal, :break, :_, :overflow, :negative)

      def initialize registers
        @registers = registers
        super(registers.sr.to_i)
      end

      def on_update name
        @registers.sr = self.to_i
      end
    end

    def status
      Status.new(self)
    end

  end
end
