require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def registers; Cpu.new.send(:registers); end

    it "initializes program counter to instruction before zero" do
      registers.pc.must_equal 0xFFFF
    end

    it "initializes accumulator to zero" do
      registers.ac.must_equal 0
    end

    it "initializes x to zero" do
      registers.x.must_equal 0
    end

    it "initializes y to zero" do
      registers.y.must_equal 0
    end

    it "initializes status to 0b00000000" do
      registers.sr.must_equal 0
    end

    it "initializes stack pointer to 0xFF" do
      registers.sp.must_equal 0xFF
    end

  end
end
