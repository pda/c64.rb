require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def registers; Cpu.new.send(:registers); end

    it "initializes program counter to instruction before zero" do
      registers.pc.must_equal -1
    end

    it "initializes accumulator to zero" do
      registers.pc.must_equal 0
    end

    it "initializes x to zero" do
      registers.pc.must_equal 0
    end

    it "initializes y to zero" do
      registers.pc.must_equal 0
    end

    it "initializes status to 0b00000000" do
      registers.pc.must_equal 0
    end

    it "initializes stack pointer to 0x01FF" do
      registers.sp.must_equal 0x01FF
    end

  end
end
