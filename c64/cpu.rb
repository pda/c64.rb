require "c64/memory"
require "c64/registers"
require "c64/instruction_decoder"
require "c64/instructions"

module C64
  class Cpu

    def initialize parameters = {}
      @memory = parameters[:memory] || Memory.new
      @registers = Registers.new.tap do |r|
        r.pc.low = memory[0xFFFC]
        r.pc.high = memory[0xFFFD]
        r.sp = 0xFF
        r.sr = 0b00000000
      end
      @decoder = InstructionDecoder.new
    end

    include Instructions

    def step
      @decoder.decode(memory[registers.pc]).tap do |i|
        registers.pc += 1
        parameters = [ i.addressing ]
        parameters << read_operand(i) if i.operand?
        registers.pc += i.operand_size
        send i.name, *parameters
      end
    end

    private

    attr_reader :memory, :registers
    alias :reg :registers

    def status
      registers.status
    end

    def read_operand instruction
      String.new.tap do |operand|
        instruction.operand_size.times do |i|
          operand << memory[registers.pc + i]
        end
      end
    end

  end
end
