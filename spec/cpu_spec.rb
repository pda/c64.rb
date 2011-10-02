require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def memory; Cpu.new.send(:memory); end
    def registers; Cpu.new.send(:registers); end

    it "initializes program counter from memory 0xFFFC and 0xFFFD" do
      cpu = Cpu.new(memory: { 0xFFFC => 0xAA, 0xFFFD => 0xBB })
      cpu.send(:registers).pc.must_equal 0xBBAA
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
