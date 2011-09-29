module C64
  class Registers < Struct.new(:pc, :ac, :x, :y, :sr, :sp)

    class Status
      def initialize sr
        @sr = sr
      end
      {
        7 => :negative?,
        6 => :overflow?,
        4 => :break?,
        3 => :decimal?,
        2 => :interrupt?,
        1 => :zero?,
        0 => :carry?
      }.each do |bit, method|
        define_method method do
          (@sr >> bit & 1) == 1
        end
      end
    end

    def status
      Status.new(sr)
    end

  end
end
