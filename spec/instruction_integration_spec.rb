require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def cpu; @cpu ||= C64::Cpu.new; end
    def registers; cpu.send :registers; end
    def memory; cpu.send :memory; end

    def load_program *bytes
      bytes.each_with_index { |byte, i| memory[i] = byte }
    end

    def step n = 1
      n.times { cpu.step }
    end

    describe :BEQ do
      it "branches forwards for z = 1" do
        registers.sr = 0b00000010
        registers.pc = 1024
        memory[1024] = 0xF0
        memory[1025] = 100
        step
        registers.pc.must_equal 1126
      end
      it "branches backwards for z = 1" do
        registers.sr = 0b00000010
        registers.pc = 1024
        memory[1024] = 0xF0
        memory[1025] = 0x9C # -100
        step
        registers.pc.must_equal 926
      end
      it "does not branch for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1024
        memory[1024] = 0xF0
        memory[1025] = 100
        step
        registers.pc.must_equal 1026
      end
    end

    describe :BNE do
      it "branches forwards for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1024
        memory[1024] = 0xD0
        memory[1025] = 100
        step
        registers.pc.must_equal 1126
      end
      it "branches backwards for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1024
        memory[1024] = 0xD0
        memory[1025] = 0x9C # -100
        step
        registers.pc.must_equal 926
      end
      it "does not branch for z = 1" do
        registers.sr = 0b00000010
        registers.pc = 1024
        memory[1024] = 0xD0
        memory[1025] = 100
        step
        registers.pc.must_equal 1026
      end
    end

    describe :INX do
      it "increments x by one" do
        load_program 0xE8
        step
        registers.x.must_equal 1
      end
    end

    describe :INY do
      it "increments y by one" do
        load_program 0xC8
        step
        registers.y.must_equal 1
      end
    end

    describe :JSR do
      it "stores PC, jumps to address" do
        registers.pc = 1000
        memory[1000] = 0x20
        memory[1001] = 0xAD
        memory[1002] = 0xDE
        step
        registers.pc.must_equal 0xDEAD

        # The return address pushed to the stack by JSR is that of the
        # last byte of the JSR operand (that is, the most significant
        # byte of the subroutine address), rather than the address of
        # the following instruction.
        # http://en.wikipedia.org/wiki/MOS_Technology_6502#Bugs_and_quirks

        # little-endian 0xEA03 == 1002
        memory[registers.sp + 0].must_equal 0xEA
        memory[registers.sp + 1].must_equal 0x03
      end
    end

    describe :LDX do
      it "loads immediate value into X register" do
        load_program 0xA2, 123
        step
        registers.pc.must_equal 2
        registers.x.must_equal 123
      end
    end

    describe :LDY do
      it "loads immediate value into Y register" do
        load_program 0xA0, 123
        step
        registers.pc.must_equal 2
        registers.y.must_equal 123
      end
    end

    describe :NOP do
      it "does nothing" do
        load_program 0xEA
        step
        registers.pc.must_equal 1
      end
    end

    describe :RTS do
      it "works" do
        sp = registers.sp
        load_program 0x20, 0xAD, 0xDE # JSR to 0xDEAD
        memory[0xDEAD] = 0x60         # RTS
        step 2
        registers.pc.must_equal 0x03
        registers.sp.must_equal sp
      end
    end

    describe :STX do
      it "stores X into memory (absolute)" do
        load_program \
          0xA2, 123, # LDX
          0x8E, 0xAD, 0xDE # STX
        step 2
        registers.pc.must_equal 5
        memory[0xDEAD].must_equal 123
      end
    end

    describe :STY do
      it "stores Y into memory (absolute)" do
        load_program \
          0xA0, 123, # LDY
          0x8C, 0xAD, 0xDE # STY
        step 2
        registers.pc.must_equal 5
        memory[0xDEAD].must_equal 123
      end
    end

  end
end
