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
        registers.pc = 1023
        memory[1024] = 0xF0
        memory[1025] = 100
        step
        registers.pc.must_equal 1125
      end
      it "branches backwards for z = 1" do
        registers.sr = 0b00000010
        registers.pc = 1023
        memory[1024] = 0xF0
        memory[1025] = 0x9C # -100
        step
        registers.pc.must_equal 925
      end
      it "does not branch for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1023
        memory[1024] = 0xF0
        memory[1025] = 100
        step
        registers.pc.must_equal 1025
      end
    end

    describe :BNE do
      it "branches forwards for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1023
        memory[1024] = 0xD0
        memory[1025] = 100
        step
        registers.pc.must_equal 1125
      end
      it "branches backwards for z = 0" do
        registers.sr = 0b00000000
        registers.pc = 1023
        memory[1024] = 0xD0
        memory[1025] = 0x9C # -100
        step
        registers.pc.must_equal 925
      end
      it "does not branch for z = 1" do
        registers.sr = 0b00000010
        registers.pc = 1023
        memory[1024] = 0xD0
        memory[1025] = 100
        step
        registers.pc.must_equal 1025
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
        memory[1001] = 0x20
        memory[1002] = 0xAD
        memory[1003] = 0xDE
        step
        registers.pc.must_equal 0xDEAD - 1

        # The return address pushed to the stack by JSR is that of the
        # last byte of the JSR operand (that is, the most significant
        # byte of the subroutine address), rather than the address of
        # the following instruction.
        # http://en.wikipedia.org/wiki/MOS_Technology_6502#Bugs_and_quirks

        # little-endian 0xEB03 == 1003
        memory[registers.sp + 1].must_equal 0xEB
        memory[registers.sp + 2].must_equal 0x03
      end
    end

    { ac: 0xA9, x: 0xA2, y: 0xA0 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} immediate" do
        it "loads immediate value into #{reg} register" do
          load_program op, 123
          step
          registers.pc.must_equal 1
          registers[reg].must_equal 123
        end
      end
    end

    { ac: 0xA5, x: 0xA6, y: 0xA4 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} zeropage" do
        it "loads zeropage value into #{reg} register" do
          load_program op, 0x10
          memory[0x10] = 32
          step
          registers.pc.must_equal 1
          registers[reg].must_equal 32
        end
      end
    end

    { ac: 0xB5, y: 0xB4 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} zeropage_x" do
        it "loads zeropage X-indexed value into #{reg} register" do
          load_program op, 0x10
          registers.x = 0x04
          memory[0x10 + 0x04] = 32
          step
          registers.pc.must_equal 1
          registers[reg].must_equal 32
        end
      end
    end

    describe "LDX zeropage_y" do
      it "loads zeropage Y-indexed value into X register" do
        load_program 0xB6, 0x10
        registers.y = 0x04
        memory[0x10 + 0x04] = 32
        step
        registers.pc.must_equal 1
        registers.x.must_equal 32
      end
    end

    describe "LDA setting SR flags" do
      it "sets zero flag off" do
        registers.status.zero = true
        load_program 0xA9, 0x01 ; step
        registers.status.zero?.must_equal false
      end
      it "sets zero flag on" do
        load_program 0xA9, 0x00 ; step
        registers.status.zero?.must_equal true
      end
    end

    describe :NOP do
      it "does nothing" do
        load_program 0xEA
        step
        registers.pc.must_equal 0
      end
    end

    describe :RTS do
      it "returns from subroutine, restores stack pointer" do
        sp = registers.sp
        load_program 0x20, 0xAD, 0xDE # JSR to 0xDEAD
        memory[0xDEAD] = 0x60         # RTS
        step 2
        registers.pc.must_equal 0x02
        registers.sp.must_equal sp
      end
    end

    describe :STX do
      it "stores X into memory (absolute)" do
        load_program \
          0xA2, 123, # LDX
          0x8E, 0xAD, 0xDE # STX
        step 2
        registers.pc.must_equal 4
        memory[0xDEAD].must_equal 123
      end
    end

    describe :STY do
      it "stores Y into memory (absolute)" do
        load_program \
          0xA0, 123, # LDY
          0x8C, 0xAD, 0xDE # STY
        step 2
        registers.pc.must_equal 4
        memory[0xDEAD].must_equal 123
      end
    end

  end
end
