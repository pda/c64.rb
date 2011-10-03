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
      value = case addr
      when :immediate   then uint8(op)
      else raise "todo: #{addr}"
      end
      registers.ac &= value
      # todo: set status flags
    end

    # arithmetic shift left
    def ASL addr, op = nil
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
    def BRK addr
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
    def CLC addr
      raise "TODO"
    end

    # clear decimal
    def CLD addr
      registers.status.decimal = false
    end

    # clear interrupt disable
    def CLI addr
      raise "TODO"
    end

    # clear overflow
    def CLV addr
      raise "TODO"
    end

    # compare (with accumulator)
    def CMP addr, op
      value = case addr
      when :absolute_x then memory[uint16(op) + registers.x]
      when :indirect_y then memory[memory[uint16(op) + registers.y]]
      else raise "TODO: #{addr}"
      end
      registers.status.tap do |s|
        s.zero = registers.ac == value
        s.carry = registers.ac >= value
        s.negative = value >> 7 == 1
      end
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
      address = case addr
      when :zeropage   then uint8(op)
      when :absolute   then uint16(op)
      else raise "TODO: #{addr}"
      end
      memory[address] -= 1
    end

    # decrement X
    def DEX addr
      registers.x -= 1
    end

    # decrement Y
    def DEY addr
      registers.y -= 1
    end

    # exclusive or (with accumulator)
    def EOR addr, op
      raise "TODO"
    end

    # increment
    def INC addr, op
      address = case addr
      when :zeropage   then uint8(op)
      when :absolute   then uint16(op)
      else raise "TODO: #{addr}"
      end
      memory[address] += 1
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
      case addr
      when :absolute then registers.pc = uint16(op)
      when :indirect then raise "TODO"
      end
    end

    # jump subroutine
    def JSR addr, op
      ret = registers.pc - 1
      memory[registers.sp - 0] = ret.high
      memory[registers.sp - 1] = ret.low
      registers.sp -= 2
      registers.pc = uint16(op)
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
      registers[reg] = case addr
      when :immediate  then op.ord
      when :zeropage   then memory[int8(op)]
      when :zeropage_x then memory[int8(op) + registers.x.to_i] # TODO: no .to_i once int8() is Int8 instance
      when :zeropage_y then memory[int8(op) + registers.y.to_i] # TODO: same
      when :absolute   then memory[uint16(op)]
      when :absolute_x then memory[uint16(op) + registers.x]
      when :indirect_y then memory[memory[uint16(op) + registers.x]]
      else raise "TODO"
      end
      registers.status.zero = registers[reg].zero?
    end
    private :LDreg

    # logical shift right
    def LSR addr, op = nil
      raise "TODO"
    end

    # no operation
    def NOP addr
    end

    # or with accumulator
    def ORA addr, op
      value = case addr
      when :immediate   then uint8(op)
      else raise "todo: #{addr}"
      end
      registers.ac |= value
      # todo: set status flags
    end

    # push accumulator
    def PHA addr
      raise "TODO"
    end

    # push processor status (SR)
    def PHP addr
      raise "TODO"
    end

    # pull accumulator
    def PLA addr
      raise "TODO"
    end

    # pull processor status (SR)
    def PLP addr, op
      raise "TODO"
    end

    # rotate left
    def ROL addr, op = nil
      raise "TODO"
    end

    # rotate right
    def ROR addr, op = nil
      raise "TODO"
    end

    # return from interrupt
    def RTI addr
      raise "TODO"
    end

    # return from subroutine
    def RTS addr
      registers.pc.low = memory[registers.sp + 1]
      registers.pc.high = memory[registers.sp + 2]
      registers.sp += 2
      registers.pc += 1
    end

    # subtract with carry
    def SBC addr, op
      raise "TODO"
    end

    # set carry
    def SEC addr
      raise "TODO"
    end

    # set decimal
    def SED addr
      raise "TODO"
    end

    # set interrupt disable
    def SEI addr
      registers.status.interrupt = true
    end

    # store accumulator
    def STA addr, op
      STreg :ac, addr, op
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
      address = case addr
      when :absolute   then uint16(op)
      when :absolute_x then uint16(op) + registers.x
      when :absolute_y then uint16(op) + registers.y
      when :indirect_y then memory[uint16(op) + registers.y]
      when :zeropage   then uint8(op)
      else raise "TODO: #{addr}"
      end
      memory[address] = registers[reg]
    end
    private :STreg

    # transfer accumulator to X
    def TAX addr
      registers.x = registers.ac
    end

    # transfer accumulator to Y
    def TAY addr
      registers.y = registers.ac
    end

    # transfer stack pointer to X
    def TSX addr
      raise "TODO"
    end

    # transfer X to accumulator
    def TXA addr
      raise "TODO"
    end

    # transfer X to stack pointer
    def TXS addr
      registers.sp = registers.x
    end

    # transfer Y to accumulator
    def TYA addr
      raise "TODO"
    end

    private

    def int8   str; str.unpack("c").first; end
    def uint8  str; Uint8.unpack(str); end
    def uint16 str; Uint16.unpack(str); end

  end
end
