require "c64/memory"
require "c64/registers"
require "c64/instruction_decoder"
require "c64/instructions"

module C64
  class Cpu

    def initialize
      @memory = Memory.new
      @registers = Registers.new.tap do |r|
        r.pc = 0
        r.ac = 0
        r.x = 0
        r.y = 0
        r.sr = 0
        r.sp = 0x01FF
      end
      @decoder = InstructionDecoder.new
    end

    include Instructions

    def step
      @decoder.decode(memory[registers.pc]).tap do |i|
        parameters = [ i.addressing ]
        parameters << read_operand(i) if i.operand?
        registers.pc += i.operand_size
        send i.name, *parameters
        registers.pc += 1
      end
    end

    private

    attr_reader :memory, :registers

    def read_operand instruction
      String.new.tap do |operand|
        instruction.operand_size.times do |i|
          operand << memory[registers.pc + 1 + i]
        end
      end
    end

  end
end
