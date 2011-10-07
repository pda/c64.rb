require_relative "spec_helper"
require "c64/cpu"

module C64
  describe Cpu do

    def cpu; @cpu ||= C64::Cpu.new; end
    def reg; cpu.send :registers; end
    def status; reg.status; end
    def memory; cpu.send :memory; end

    # Usage: run_instructions "AA BB", "CC DD EE", at: 0x400
    def run_instructions *i
      options = if i.last.is_a? Hash then i.pop else {} end
      offset = options[:at] || 0
      reg.pc = offset
      i.each do |instruction|
        instruction.split(" ").each do |hex|
          memory[offset] = hex.to_i(16)
          offset += 1
        end
      end
      i.length.times { cpu.step }
    end

    describe "behaviour described at http://www.6502.org/tutorials/vflag.html section 2.4.2.2" do
      def carry_and_overflow_must_equal c, v
        status.carry?.must_equal c
        status.overflow?.must_equal v
      end
      it "is correct for 1 + 1 = 2" do
        run_instructions "18", "A9 01", "69 01" # CLC; LDA; ADC
        carry_and_overflow_must_equal false, false
      end
      it "is correct for 1 + -1 = 0" do
        run_instructions "18", "A9 01", "69 FF" # CLC; LDA; ADC
        carry_and_overflow_must_equal true, false
      end
      it "is correct for 127 + 1 = 128" do
        run_instructions "18", "A9 7F", "69 01" # CLC; LDA; ADC
        carry_and_overflow_must_equal false, true
      end
      it "is correct for -128 + -1 = -129" do
        run_instructions "18", "A9 80", "69 FF" # CLC; LDA; ADC
        carry_and_overflow_must_equal true, true
      end

      it "is correct for 0 - 1 = -1" do
        run_instructions "38", "A9 00", "E9 01" # SEC; LDA; SBC
        status.overflow?.must_equal false
      end
      it "is correct for -128 - 1 = -129" do
        run_instructions "38", "A9 80", "E9 01" # SEC; LDA; SBC
        status.overflow?.must_equal true
      end
      it "is correct for 127 - -1 = 128" do
        run_instructions "38", "A9 7F", "E9 FF" # SEC; LDA; SBC
        reg.ac.must_equal 0x80
        status.overflow?.must_equal true
      end

      it "is correct for 63 + 64 + 1 = 128" do
        run_instructions "38", "A9 3F", "69 40" # SEC; LDA; ADC
        status.overflow?.must_equal true
      end
      it "is correct for -64 - 64 - 1 = -129" do
        run_instructions "18", "A9 C0", "E9 40" # CLC; LDA; SBC
        status.overflow?.must_equal true
      end
    end

    describe :ADC do
      describe "in binary mode, with 0xA4 in accumulator" do
        before do
          status.decimal = false
          reg.ac = 0xA4
        end
        describe "with carry not set" do
          before { status.carry = false }
          it "adds 0x04 = 0xA8 (clears carry)" do
            run_instructions "69 04"
            reg.ac.must_equal 0xA8
            status.carry?.must_equal false
          end
          it "adds 0xA0 = 0x44 (sets carry)" do
            run_instructions "69 A0"
            reg.ac.must_equal 0x44
            status.carry?.must_equal true
          end
        end
        describe "with carry set" do
          before { status.carry = true }
          it "adds 0x04 = 0xA9 (clears carry)" do
            run_instructions "69 04"
            reg.ac.must_equal 0xA9
            status.carry?.must_equal false
          end
          it "adds 0xA0 = 0x45 (sets carry)" do
            run_instructions "69 A0"
            reg.ac.must_equal 0x45
            status.carry?.must_equal true
          end
        end
      end
    end

    describe :AND do
      it "bitwise AND into accumulator" do
        reg.ac = 0b01010101
        run_instructions "29 F0" # AND #F0
        reg.ac.must_equal 0b01010000
      end
    end

    describe :BCC do
      it "branches for carry? false" do
        status.carry = false
        run_instructions "90 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for carry? true" do
        status.carry = true
        run_instructions "90 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :BCS do
      it "branches for carry? true" do
        status.carry = true
        run_instructions "B0 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for carry? false" do
        status.carry = false
        run_instructions "B0 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :BEQ do
      it "branches forwards for zero? true" do
        reg.sr = 0b00000010
        run_instructions "F0 04", at: 0x0400
        reg.pc.must_equal 0x0406
      end
      it "branches backwards for zero? true" do
        reg.sr = 0b00000010
        run_instructions "F0 F8", at: 0x0406
        reg.pc.must_equal 0x0400
      end
      it "does not branch for zero? false" do
        reg.sr = 0b00000000
        run_instructions "F0 08", at: 0x0400
        reg.pc.must_equal 0x0402
      end
    end

    describe :BIT do
      it "loads negative and overflow flags, sets zero based on ac AND op" do
        reg.sr = 0b00000000
        reg.ac = 0b00101010
        memory[0x00A0] = 0b11010101
        run_instructions "24 A0"
        status.negative?.must_equal true
        status.overflow?.must_equal true
        status.zero?.must_equal true # reg.ac AND [0x00A0] == 0
      end
      it "loads negative and overflow flags (unset), unsets zero based on ac AND op" do
        reg.sr = 0b11111111
        reg.ac = 0b11111111
        memory[0x00A0] = 0b00010101
        run_instructions "24 A0"
        status.negative?.must_equal false
        status.overflow?.must_equal false
        status.zero?.must_equal false # reg.ac AND [0x00A0] != 0
      end
    end

    describe :BMI do
      it "branches for negative? true" do
        status.negative = true
        run_instructions "30 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for negative? false" do
        status.negative = false
        run_instructions "30 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :BNE do
      it "branches forwards for zero? false" do
        reg.sr = 0b00000000
        run_instructions "D0 04", at: 0x0400
        reg.pc.must_equal 0x0406
      end
      it "branches backwards for zero? false" do
        reg.sr = 0b00000000
        run_instructions "D0 F8", at: 0x0406
        reg.pc.must_equal 0x0400
      end
      it "does not branch for zero? true" do
        reg.sr = 0b00000010
        run_instructions "D0 08", at: 0x0400
        reg.pc.must_equal 0x0402
      end
    end

    describe :BPL do
      it "branches for negative? false" do
        status.negative = false
        run_instructions "10 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for negative? true" do
        status.negative = true
        run_instructions "10 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :BVC do
      it "branches for overflow? false" do
        status.overflow = false
        run_instructions "50 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for overflow? true" do
        status.overflow = true
        run_instructions "50 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :BVS do
      it "branches for overflow? true" do
        status.overflow = true
        run_instructions "70 04"
        reg.pc.must_equal 0x0006
      end
      it "does not branch for overflow? false" do
        status.overflow = false
        run_instructions "70 04"
        reg.pc.must_equal 0x0002
      end
    end

    describe :CLC do
      it "clears carry flag" do
        status.carry = true
        run_instructions "18"
        status.carry?.must_equal false
      end
    end

    describe :CLD do
      it "clears decimal mode" do
        reg.status.decimal = true
        run_instructions "D8"
        reg.status.decimal?.must_equal false
      end
    end

    describe :CLV do
      it "clears overflow flag" do
        reg.status.overflow = true
        run_instructions "B8"
        reg.status.overflow?.must_equal false
      end
    end

    describe :CMP do
      it "compares memory with accumulator" do
        reg.sr = 0
        memory[0xDEAD] = 0x01
        run_instructions "A9 01", "DD AD DE" # LDA #01, CMP 0xDEAD,x
        reg.status.tap do |s|
          s.zero?.must_equal true
          s.carry?.must_equal true
          s.negative?.must_equal false
        end
      end
    end

    describe :CPX do
      it "compares memory with x" do
        reg.sr = 0
        memory[0xDEAD] = 0x01
        run_instructions "A2 01", "EC AD DE" # LDX #01, CPX 0xDEAD
        reg.status.tap do |s|
          s.zero?.must_equal true
          s.carry?.must_equal true
          s.negative?.must_equal false
        end
      end
    end

    describe :CPY do
      it "compares memory with y" do
        reg.sr = 0
        memory[0xDEAD] = 0x01
        run_instructions "A0 01", "CC AD DE" # LDY #01, CPY 0xDEAD
        reg.status.tap do |s|
          s.zero?.must_equal true
          s.carry?.must_equal true
          s.negative?.must_equal false
        end
      end
    end

    describe :DEC do
      it "decrements memory by one" do
        memory[0xDEAD] = 0xAA
        run_instructions "CE AD DE" # DEC #0xDEAD
        memory[0xDEAD].must_equal 0xA9
      end
    end

    describe :DEX do
      it "decrements x by one" do
        run_instructions "A2 AA", "CA" # LDX #AA, DEX
        reg.x.must_equal 0xA9
      end
    end

    describe :DEY do
      it "decrements y by one" do
        run_instructions "A0 AA", "88" # LDY #AA, DEY
        reg.y.must_equal 0xA9
      end
    end

    describe :INC do
      it "increments memory by one" do
        memory[0xDEAD] = 0xAA
        run_instructions "EE AD DE" # INC #0xDEAD
        memory[0xDEAD].must_equal 0xAB
      end
    end

    describe :INX do
      it "increments x by one" do
        run_instructions "E8"
        reg.x.must_equal 1
      end
    end

    describe :INY do
      it "increments y by one" do
        run_instructions "C8"
        reg.y.must_equal 1
      end
    end

    describe :JMP do
      it "updates program counter" do
        run_instructions "4C AD DE" # JMP #0xDEAD
        reg.pc.must_equal 0xDEAD
      end
    end

    describe :JSR do
      it "stores PC, jumps to address" do
        run_instructions "20 AD DE", at: 1000
        reg.pc.must_equal 0xDEAD

        # The return address pushed to the stack by JSR is that of the
        # last byte of the JSR operand (that is, the most significant
        # byte of the subroutine address), rather than the address of
        # the following instruction.
        # http://en.wikipedia.org/wiki/MOS_Technology_6502#Bugs_and_quirks

        # little-endian 0xEA03 == 1002
        memory[0x01FE].must_equal 0xEA # "top" of stack
        memory[0x01FF].must_equal 0x03 # second-to-"top" of stack
      end
    end

    { ac: 0xA9, x: 0xA2, y: 0xA0 }.each do |r, op|
      describe "LD#{r.to_s[0].upcase} immediate" do
        it "loads immediate value into #{r} register" do
          run_instructions "#{op.to_s(16)} AA"
          reg[r].must_equal 0xAA
        end
      end
    end

    { ac: 0xA5, x: 0xA6, y: 0xA4 }.each do |r, op|
      describe "LD#{r.to_s[0].upcase} zeropage" do
        it "loads zeropage value into #{r} register" do
          memory[0xC2] = 0xAA
          run_instructions "#{op.to_s(16)} C2"
          reg[r].must_equal 0xAA
        end
      end
    end

    { ac: 0xB5, y: 0xB4 }.each do |r, op|
      describe "LD#{r.to_s[0].upcase} zeropage_x" do
        it "loads zeropage X-indexed value into #{r} register" do
          reg.x = 0x04
          memory[0x10 + 0x04] = 0xAA
          run_instructions "#{op.to_s(16)} 10"
          reg[r].must_equal 0xAA
        end
      end
    end

    describe "LDX zeropage_y" do
      it "loads zeropage Y-indexed value into X register" do
        reg.y = 0x04
        memory[0x10 + 0x04] = 0xAA
        run_instructions "B6 10"
        reg.x.must_equal 0xAA
      end
    end

    describe "LDA setting SR flags" do
      it "sets zero flag off" do
        reg.status.zero = true
        run_instructions "A9 01"
        reg.status.zero?.must_equal false
      end
      it "sets zero flag on" do
        run_instructions "A9 00"
        reg.status.zero?.must_equal true
      end
    end

    describe :NOP do
      it "does nothing" do
        run_instructions "EA"
        reg.pc.must_equal 1
      end
    end

    describe :ORA do
      it "bitwise OR into accumulator" do
        reg.ac = 0b01010101
        run_instructions "09 F0" # AND #F0
        reg.ac.must_equal 0b11110101
      end
    end

    describe :ROL do
      it "shifts left one bit, carry into low bit, high bit into carry" do
        reg.status.carry = false
        reg.ac = 0b10101010
        run_instructions "2A"
        reg.ac.must_equal 0b01010100
        reg.status.carry?.must_equal true
      end
    end

    describe :ROR do
      it "shifts right one bit, carry into high bit, low bit into carry" do
        reg.status.carry = true
        reg.ac = 0b10101010
        run_instructions "6A"
        reg.ac.must_equal 0b11010101
        reg.status.carry?.must_equal false
      end
    end

    describe :RTS do
      it "returns from subroutine, restores stack pointer" do
        sp = reg.sp
        memory[0xDEAD] = 0x60       # RTS
        run_instructions "20 AD DE" # JSR to 0xDEAD
        cpu.step
        reg.pc.must_equal 0x03
        reg.sp.must_equal sp
      end
    end

    describe :SBC do
      describe "in binary mode, with 0x08 in accumulator" do
        before do
          status.decimal = false
          reg.ac = 0x08
        end
        describe "with carry not set" do
          before { status.carry = false }
          it "subtracts 0x04 = 0x04 (sets carry)" do
            run_instructions "E9 04"
            reg.ac.must_equal 0x03
            status.carry?.must_equal true
          end
          it "subtracts 0x10 = 0xF4 (clears carry)" do
            run_instructions "E9 10"
            reg.ac.must_equal 0xF7
            status.carry?.must_equal false
          end
        end
        describe "with carry set" do
          before { status.carry = true }
          it "subtracts 0x04 = 0x03 (sets carry)" do
            run_instructions "E9 04"
            reg.ac.must_equal 0x04
            status.carry?.must_equal true
          end
          it "subtracts 0x10 = 0xF3 (clears carry)" do
            run_instructions "E9 10"
            reg.ac.must_equal 0xF8
            status.carry?.must_equal false
          end
        end
      end
    end

    describe :SEC do
      it "sets carry flag" do
        status.carry = false
        run_instructions "38"
        status.carry?.must_equal true
      end
    end

    #describe :SED do
    #  it "sets decimal flag" do
    #    status.decimal = false
    #    run_instructions "F8"
    #    status.decimal?.must_equal true
    #  end
    #end

    describe :SEI do
      it "sets interrupt disable" do
        reg.status.interrupt = false
        run_instructions "78"
        reg.status.interrupt?.must_equal true
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

    describe :TAX do
      it "transfers accumulator to X" do
        run_instructions "A9 AA", "AA" # LDA, TAX
        reg.x.must_equal 0xAA
      end
    end

    describe :TAY do
      it "transfers accumulator to Y" do
        run_instructions "A9 AA", "A8" # LDA, TAY
        reg.y.must_equal 0xAA
      end
    end

    describe :TSX do
      it "transfers stack pointer to X" do
        reg.sp = 0xAA
        run_instructions "BA"
        reg.x.must_equal 0xAA
        status.zero?.must_equal false
        status.negative?.must_equal true
      end
    end

    describe :TXA do
      it "transfers X to accumulator" do
        run_instructions "A2 AA", "A0 00", "8A" # LDX 0xAA, LDY 0x00, TXA
        reg.ac.must_equal 0xAA
        status.zero?.must_equal false
        status.negative?.must_equal true
      end
      it "sets zero flag for zero value" do
        run_instructions "A2 00", "A0 01", "8A" # LDX 0x00, LDY 0x01, TXA
        reg.ac.must_equal 0x00
        status.zero?.must_equal true
        status.negative?.must_equal false
      end
    end

    describe :TYA do
      it "transfers Y to accumulator" do
        run_instructions "A0 AA", "A2 00", "98" # LDY 0xAA, LDX 0x00, TYA
        reg.ac.must_equal 0xAA
        status.zero?.must_equal false
        status.negative?.must_equal true
      end
      it "sets zero flag for zero value" do
        run_instructions "A0 00", "A2 01", "98" # LDY 0x00, LDX 0x01, TYA
        reg.ac.must_equal 0x00
        status.zero?.must_equal true
        status.negative?.must_equal false
      end
    end

    describe :TXS do
      it "transfers X to stack pointer" do
        run_instructions "A2 AA", "9A" # LDS, TXS
        reg.sp.must_equal 0xAA
      end
    end

  end
end
