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
      reg.ac &= value
      set_status_flags reg.ac
    end

    # arithmetic shift left
    def ASL addr, op = nil
      raise "TODO"
      # TODO: set_status_flags
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
      reg.pc += int8(op) if status.zero?
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
      reg.pc += int8(op) unless status.zero?
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
      status.carry = false
    end

    # clear decimal
    def CLD addr
      status.decimal = false
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
      when :absolute_x then memory[uint16(op) + reg.x]
      when :indirect_y then memory[memory[uint16(op) + reg.y]]
      else raise "TODO: #{addr}"
      end
      status.zero = reg.ac == value
      status.carry = reg.ac >= value
      status.negative = value >> 7 == 1
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
      set_status_flags memory[address]
    end

    # decrement X
    def DEX addr
      reg.x -= 1
      set_status_flags reg.x
    end

    # decrement Y
    def DEY addr
      reg.y -= 1
      set_status_flags reg.y
    end

    # exclusive or (with accumulator)
    def EOR addr, op
      raise "TODO"
      # TODO: set_status_flags
    end

    # increment
    def INC addr, op
      address = case addr
      when :zeropage   then uint8(op)
      when :absolute   then uint16(op)
      else raise "TODO: #{addr}"
      end
      memory[address] += 1
      set_status_flags memory[address]
    end

    # increment X
    def INX addr
      reg.x += 1
      set_status_flags reg.x
    end

    # increment Y
    def INY addr
      reg.y += 1
      set_status_flags reg.y
    end

    # jump
    def JMP addr, op
      case addr
      when :absolute then reg.pc = uint16(op)
      when :indirect then raise "TODO"
      end
    end

    # jump subroutine
    def JSR addr, op
      ret = reg.pc - 1
      memory[reg.sp - 0] = ret.high
      memory[reg.sp - 1] = ret.low
      reg.sp -= 2
      reg.pc = uint16(op)
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

    def LDreg r, addr, op
      reg[r] = case addr
      when :immediate  then op.ord
      when :zeropage   then memory[uint8(op)]
      when :zeropage_x then memory[uint8(op) + reg.x]
      when :zeropage_y then memory[uint8(op) + reg.y]
      when :absolute   then memory[uint16(op)]
      when :absolute_x then memory[uint16(op) + reg.x]
      when :indirect_y then memory[memory[uint16(op) + reg.x]]
      else raise "TODO"
      end
      set_status_flags reg[r]
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
      reg.ac |= value
      set_status_flags reg.ac
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
      # TODO: set_status_flags
    end

    # pull processor status (SR)
    def PLP addr, op
      raise "TODO"
    end

    # rotate left
    def ROL addr, op = nil
      case addr
      when :accumulator
        carry = status.carry? ? 1 : 0
        status.carry = reg.ac >> 7
        reg.ac = (reg.ac << 1) | carry
        set_status_flags reg.ac
      else raise "TODO: #{addr}"
      end
    end

    # rotate right
    def ROR addr, op = nil
      case addr
      when :accumulator
        carry = status.carry? ? 1 : 0
        status.carry = reg.ac & 0x01
        reg.ac = (reg.ac >> 1) | carry << 7
        set_status_flags reg.ac
      else raise "TODO: #{addr}"
      end
    end

    # return from interrupt
    def RTI addr
      raise "TODO"
    end

    # return from subroutine
    def RTS addr
      reg.pc.low = memory[reg.sp + 1]
      reg.pc.high = memory[reg.sp + 2]
      reg.sp += 2
      reg.pc += 1
    end

    # subtract with carry
    def SBC addr, op
      raise "TODO"
      set_status_flags reg.ac
    end

    # set carry
    def SEC addr
      status.carry = true
    end

    # set decimal
    def SED addr
      status.decimal = true
    end

    # set interrupt disable
    def SEI addr
      status.interrupt = true
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

    def STreg r, addr, op
      address = case addr
      when :absolute   then uint16(op)
      when :absolute_x then uint16(op) + reg.x
      when :absolute_y then uint16(op) + reg.y
      when :indirect_y then memory[uint16(op) + reg.y]
      when :zeropage   then uint8(op)
      else raise "TODO: #{addr}"
      end
      memory[address] = reg[r]
    end
    private :STreg

    # transfer accumulator to X
    def TAX addr
      reg.x = reg.ac
      set_status_flags reg.x
    end

    # transfer accumulator to Y
    def TAY addr
      reg.y = reg.ac
      set_status_flags reg.y
    end

    # transfer stack pointer to X
    def TSX addr
      reg.x = reg.sp
      set_status_flags reg.x
    end

    # transfer X to accumulator
    def TXA addr
      reg.ac = reg.x
      set_status_flags reg.ac
    end

    # transfer X to stack pointer
    def TXS addr
      reg.sp = reg.x
      set_status_flags reg.sp
    end

    # transfer Y to accumulator
    def TYA addr
      reg.ac = reg.y
      set_status_flags reg.ac
    end

    private

    def int8   str; str.unpack("c").first; end
    def uint8  str; Uint8.unpack(str); end
    def uint16 str; Uint16.unpack(str); end

    def set_status_flags value
      status.zero = value.zero?
      status.negative = value >> 7
    end

  end
end
