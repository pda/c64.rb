module C64
  module Instructions

    # Thanks to:
    # http://www.masswerk.at/6502/6502_instruction_set.html

    # add with carry
    def ADC addr, op
      raise "TODO"
    end

    # and (with accumulator)
    def AND addr, op
      raise "TODO"
    end

    # arithmetic shift left
    def ASL addr, op
      raise "TODO"
    end

    # branch on carry clear
    def BCC addr, op
      raise "TODO"
    end

    # branch on carry set
    def BCS addr, op
      raise "TODO"
    end

    # branch on equal (zero set)
    # (branch on z = 1)
    def BEQ addr, op
      registers.pc += int8(op) if registers.status.zero?
    end

    # bit test
    def BIT addr, op
      raise "TODO"
    end

    # branch on minus (negative set)
    def BMI addr, op
      raise "TODO"
    end

    # branch on not equal (zero clear)
    def BNE addr, op
      registers.pc += int8(op) unless registers.status.zero?
    end

    # branch on plus (negative clear)
    def BPL addr, op
      raise "TODO"
    end

    # interrupt
    def BRK addr, op
      raise "TODO"
    end

    # branch on overflow clear
    def BVC addr, op
      raise "TODO"
    end

    # branch on overflow set
    def BVS addr, op
      raise "TODO"
    end

    # clear carry
    def CLC addr, op
      raise "TODO"
    end

    # clear decimal
    def CLD addr, op
      raise "TODO"
    end

    # clear interrupt disable
    def CLI addr, op
      raise "TODO"
    end

    # clear overflow
    def CLV addr, op
      raise "TODO"
    end

    # compare (with accumulator)
    def CMP addr, op
      raise "TODO"
    end

    # compare with X
    def CPX addr, op
      raise "TODO"
    end

    # compare with Y
    def CPY addr, op
      raise "TODO"
    end

    # decrement
    def DEC addr, op
      raise "TODO"
    end

    # decrement X
    def DEX addr, op
      raise "TODO"
    end

    # decrement Y
    def DEY addr, op
      raise "TODO"
    end

    # exclusive or (with accumulator)
    def EOR addr, op
      raise "TODO"
    end

    # increment
    def INC addr, op
      raise "TODO"
    end

    # increment X
    def INX addr
      registers.x += 1
    end

    # increment Y
    def INY addr
      registers.y += 1
    end

    # jump
    def JMP addr, op
      raise "TODO"
    end

    # jump subroutine
    def JSR addr, op
      pc_hi = registers.pc >> 8
      pc_lo = registers.pc & 0xFF
      memory[registers.sp - 1] = pc_hi
      memory[registers.sp - 2] = pc_lo
      registers.sp -= 2
      registers.pc = uint16(op) - 1
    end

    # load accumulator
    def LDA addr, op
      LDreg :ac, addr, op
    end

    # load X
    def LDX addr, op
      LDreg :x, addr, op
    end

    # load Y
    def LDY addr, op
      LDreg :y, addr, op
    end

    def LDreg reg, addr, op
      case addr
      when :immediate
        registers[reg] = op.ord
      else
        raise "TODO"
      end
    end
    private :LDreg

    # logical shift right
    def LSR addr, op
      raise "TODO"
    end

    # no operation
    def NOP addr
    end

    # or with accumulator
    def ORA addr, op
      raise "TODO"
    end

    # push accumulator
    def PHA addr, op
      raise "TODO"
    end

    # push processor status (SR)
    def PHP addr, op
      raise "TODO"
    end

    # pull accumulator
    def PLA addr, op
      raise "TODO"
    end

    # pull processor status (SR)
    def PLP addr, op
      raise "TODO"
    end

    # rotate left
    def ROL addr, op
      raise "TODO"
    end

    # rotate right
    def ROR addr, op
      raise "TODO"
    end

    # return from interrupt
    def RTI addr, op
      raise "TODO"
    end

    # return from subroutine
    def RTS addr
      ret_lo = memory[registers.sp + 0]
      ret_hi = memory[registers.sp + 1]
      ret = (ret_hi << 8) + ret_lo
      registers.sp += 2
      registers.pc = ret
    end

    # subtract with carry
    def SBC addr, op
      raise "TODO"
    end

    # set carry
    def SEC addr, op
      raise "TODO"
    end

    # set decimal
    def SED addr, op
      raise "TODO"
    end

    # set interrupt disable
    def SEI addr, op
      raise "TODO"
    end

    # store accumulator
    def STA addr, op
      STreg :a, addr, op
    end

    # store X
    def STX addr, op
      STreg :x, addr, op
    end

    # store Y
    def STY addr, op
      STreg :y, addr, op
    end

    def STreg reg, addr, op
      case addr
      when :absolute
        memory[uint16(op)] = registers[reg]
      else
        raise "TODO"
      end
    end
    private :STreg

    # transfer accumulator to X
    def TAX addr, op
      raise "TODO"
    end

    # transfer accumulator to Y
    def TAY addr, op
      raise "TODO"
    end

    # transfer stack pointer to X
    def TSX addr, op
      raise "TODO"
    end

    # transfer X to accumulator
    def TXA addr, op
      raise "TODO"
    end

    # transfer X to stack pointer
    def TXS addr, op
      raise "TODO"
    end

    # transfer Y to accumulator
    def TYA addr, op
      raise "TODO"
    end

    private

    def int8   str; str.unpack("c").first; end
    def uint8  str; str.unpack("C").first; end
    def uint16 str; str.unpack("v").first; end

  end
end
