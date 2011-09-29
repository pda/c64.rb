module C64
  class Instruction < Struct.new(:name, :addressing, :bytes, :cycles, :flags)

    def operand?
      operand_size > 0
    end

    def operand_size
      bytes - 1
    end

  end
end
