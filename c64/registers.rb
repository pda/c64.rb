require "c64/data_types"

module C64
  class Registers

    def initialize pc = 0, ac = 0, x = 0, y = 0, sr = 0, sp = 0
      @pc = Uint16.new pc
      @ac = Uint8.new ac
      @x = Uint8.new x
      @y = Uint8.new y
      @sp = Uint8.new sp
      @sr = sr
    end

    # register readers
    def pc; @pc end
    def ac; @ac end
    def x; @x end
    def y; @y end
    def sp; @sp end
    def sr; @sr end

    # register writers
    def pc= value; @pc.update value end
    def ac= value; @ac.update value end
    def x= value; @x.update value end
    def y= value; @y.update value end
    def sp= value; @sp.update value end
    def sr= value; @sr = value end

    # array-access reader
    def [] register
      send register
    end

    # array-access writer
    def []= register, value
      send "#{register}=", value
    end

    class Status

      FLAGS = {
        negative:  7,
        overflow:  6,
        break:     4,
        decimal:   3,
        interrupt: 2,
        zero:      1,
        carry:     0
      }

      def initialize registers
        @registers = registers
      end

      def to_i
        @registers.sr
      end

      FLAGS.each do |flag, bit|
        define_method "#{flag}?" do
          (@registers.sr >> bit & 1) == 1
        end
        define_method "#{flag}=" do |on|
          if on
            @registers.sr |= 1 << bit
          else
            @registers.sr &= ~(1 << bit)
          end
        end
      end
    end

    def status
      Status.new(self)
    end

  end
end
