require "c64/memory"
require "c64/registers"
require "c64/instruction_decoder"
require "c64/instructions"

module C64
  class Cpu

    def initialize
      @memory = Memory.new
      @registers = Registers.new.tap do |r|
        r.pc = -1 # TODO: start at 0xFFFF, where 0xFFFF + 1 == 0x0000
        r.ac = 0
        r.x = 0
        r.y = 0
        r.sr = 0
        r.sp = 0xFF
      end
      @decoder = InstructionDecoder.new
    end

    include Instructions

    def step
      registers.pc += 1
      @decoder.decode(memory[registers.pc]).tap do |i|
        registers.pc += i.operand_size
        parameters = [ i.addressing ]
        parameters << read_operand(i) if i.operand?
        send i.name, *parameters
      end
    end

    private

    attr_reader :memory, :registers

    def read_operand instruction
      String.new.tap do |operand|
        (instruction.operand_size - 1).downto(0) do |i|
          operand << memory[registers.pc - i]
        end
      end
    end

  end
end
