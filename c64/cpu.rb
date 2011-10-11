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
        r.sp = 0xFF # address within second page of memory (0x0100 ~ 0x01FF)
        r.sr = 0b00000000
      end
      @decoder = InstructionDecoder.new

      # counters
      @cycles = 0
      @instructions = 0
    end

    # counters
    attr_reader :cycles, :instructions

    include Instructions

    def step
      @decoder.decode(memory[registers.pc]).tap do |i|
        registers.pc += 1
        parameters = [ i.addressing ]
        parameters << read_operand(i) if i.operand?
        puts "PC:0x%04X OP:0x%02X %06s => %s" % [
          reg.pc - 1,
          memory[registers.pc - 1],
          i.operand? ? "0x"+parameters[1].bytes.map{|b| b.to_s(16) }.join.upcase : "",
          i.inspect
        ] if ENV["VERBOSE"] && ENV["VERBOSE"].include?("i")
        registers.pc += i.operand_size
        send i.name, *parameters
        @cycles += i.cycles
        @instructions += 1
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
