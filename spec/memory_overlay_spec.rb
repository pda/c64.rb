require_relative "spec_helper"
require "c64/memory_overlay"
require "c64/memory"

module C64
  describe MemoryOverlay do

    it "overlays for reads" do
      ram = Memory.new(0x20) # 32 bytes
      rom = Memory.new(0x08) #  8 bytes
      offset = 0x10          # 16 bytes

      mem = MemoryOverlay.new(ram, rom, 0x10)

      ram[0x00] = 0xAA
      ram[0x10] = 0xBB
      ram[0x1F] = 0xCC

      rom[0x00] = 0x11
      rom[0x07] = 0x22

      mem[0x00].must_equal 0xAA
      mem[0x10].must_equal 0x11
      mem[0x17].must_equal 0x22
      mem[0x1F].must_equal 0xCC
    end

    it "overlays for writes" do
      ram = Memory.new(0x20) # 32 bytes
      rom = Memory.new(0x08) #  8 bytes
      offset = 0x10          # 16 bytes

      mem = MemoryOverlay.new(ram, rom, 0x10)

      mem[0x00] = 0xAA
      mem[0x10] = 0xBB
      mem[0x17] = 0xCC
      mem[0x1F] = 0xDD

      ram[0x00].must_equal 0xAA
      ram[0x1F].must_equal 0xDD

      rom[0x00].must_equal 0xBB
      rom[0x07].must_equal 0xCC
    end

  end
end
