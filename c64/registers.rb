module C64
  class Registers < Struct.new(:pc, :ac, :x, :y, :sr, :sp)

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

      def initialize sr
        @sr = sr
      end

      def to_i
        @sr
      end

      FLAGS.each do |flag, bit|
        define_method "#{flag}?" do
          (@sr >> bit & 1) == 1
        end
        define_method "#{flag}=" do |on|
          if on
            @sr |= 1 << bit
          else
            @sr &= ~(1 << bit)
          end
        end
      end
    end

    def status
      Status.new(sr)
    end

  end
end
