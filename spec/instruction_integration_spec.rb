require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def cpu; @cpu ||= C64::Cpu.new; end
    def registers; cpu.send :registers; end
    def memory; cpu.send :memory; end

    # Usage: run_instructions "AA BB", "CC DD EE", at: 0x400
    def run_instructions *i
      options = if i.last.is_a? Hash then i.pop else {} end
      offset = options[:at] || 0
      registers.pc = offset
      i.each do |instruction|
        instruction.split(" ").each do |hex|
          memory[offset] = hex.to_i(16)
          offset += 1
        end
      end
      i.length.times { cpu.step }
    end

    describe :BEQ do
      it "branches forwards for zero? true" do
        registers.sr = 0b00000010
        run_instructions "F0 04", at: 0x0400
        registers.pc.must_equal 0x0406
      end
      it "branches backwards for zero? true" do
        registers.sr = 0b00000010
        run_instructions "F0 F8", at: 0x0406
        registers.pc.must_equal 0x0400
      end
      it "does not branch for zero? false" do
        registers.sr = 0b00000000
        run_instructions "F0 08", at: 0x0400
        registers.pc.must_equal 0x0402
      end
    end

    describe :BNE do
      it "branches forwards for zero? false" do
        registers.sr = 0b00000000
        run_instructions "D0 04", at: 0x0400
        registers.pc.must_equal 0x0406
      end
      it "branches backwards for zero? false" do
        registers.sr = 0b00000000
        run_instructions "D0 F8", at: 0x0406
        registers.pc.must_equal 0x0400
      end
      it "does not branch for zero? true" do
        registers.sr = 0b00000010
        run_instructions "D0 08", at: 0x0400
        registers.pc.must_equal 0x0402
      end
    end

    describe :INX do
      it "increments x by one" do
        run_instructions "E8"
        registers.x.must_equal 1
      end
    end

    describe :INY do
      it "increments y by one" do
        run_instructions "C8"
        registers.y.must_equal 1
      end
    end

    describe :JSR do
      it "stores PC, jumps to address" do
        run_instructions "20 AD DE", at: 1000
        registers.pc.must_equal 0xDEAD

        # The return address pushed to the stack by JSR is that of the
        # last byte of the JSR operand (that is, the most significant
        # byte of the subroutine address), rather than the address of
        # the following instruction.
        # http://en.wikipedia.org/wiki/MOS_Technology_6502#Bugs_and_quirks

        # little-endian 0xEA03 == 1002
        memory[registers.sp + 1].must_equal 0xEA
        memory[registers.sp + 2].must_equal 0x03
      end
    end

    { ac: 0xA9, x: 0xA2, y: 0xA0 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} immediate" do
        it "loads immediate value into #{reg} register" do
          run_instructions "#{op.to_s(16)} AA"
          registers[reg].must_equal 0xAA
        end
      end
    end

    { ac: 0xA5, x: 0xA6, y: 0xA4 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} zeropage" do
        it "loads zeropage value into #{reg} register" do
          memory[0x10] = 0xAA
          run_instructions "#{op.to_s(16)} 10"
          registers[reg].must_equal 0xAA
        end
      end
    end

    { ac: 0xB5, y: 0xB4 }.each do |reg, op|
      describe "LD#{reg.to_s[0].upcase} zeropage_x" do
        it "loads zeropage X-indexed value into #{reg} register" do
          registers.x = 0x04
          memory[0x10 + 0x04] = 0xAA
          run_instructions "#{op.to_s(16)} 10"
          registers[reg].must_equal 0xAA
        end
      end
    end

    describe "LDX zeropage_y" do
      it "loads zeropage Y-indexed value into X register" do
        registers.y = 0x04
        memory[0x10 + 0x04] = 0xAA
        run_instructions "B6 10"
        registers.x.must_equal 0xAA
      end
    end

    describe "LDA setting SR flags" do
      it "sets zero flag off" do
        registers.status.zero = true
        run_instructions "A9 01"
        registers.status.zero?.must_equal false
      end
      it "sets zero flag on" do
        run_instructions "A9 00"
        registers.status.zero?.must_equal true
      end
    end

    describe :NOP do
      it "does nothing" do
        run_instructions "EA"
        registers.pc.must_equal 1
      end
    end

    describe :RTS do
      it "returns from subroutine, restores stack pointer" do
        sp = registers.sp
        memory[0xDEAD] = 0x60       # RTS
        run_instructions "20 AD DE" # JSR to 0xDEAD
        cpu.step
        registers.pc.must_equal 0x03
        registers.sp.must_equal sp
      end
    end

    describe :STX do
      it "stores X into memory (absolute)" do
        run_instructions "A2 AA", "8E AD DE" # LDX, STX
        memory[0xDEAD].must_equal 0xAA
      end
    end

    describe :STY do
      it "stores Y into memory (absolute)" do
        run_instructions "A0 AA", "8C AD DE" # LDY, STY
        memory[0xDEAD].must_equal 0xAA
      end
    end

  end
end
