#!env ruby
$LOAD_PATH.unshift "."
require "c64/cpu"
require "c64/memory"
require "c64/memory_overlay"

module C64

  ram =    Memory.new(0x10000) # 64k
  kernal = Memory.new(0x2000, image: "rom/kernal.rom") # 8k
  char =   Memory.new(0x1000, image: "rom/character.rom") # 4k
  basic =  Memory.new(0x2000, image: "rom/basic.rom") # 8k

  memory = MemoryOverlay.new(
    MemoryOverlay.new(
      MemoryOverlay.new(
        ram,
        kernal,
        0xE000
      ),
      char,
      0xD000
    ),
    basic,
    0xA000
  )

  cpu = Cpu.new memory: memory

  begin
    loop { cpu.step }
  ensure
    puts
    p cpu
    puts
    puts "Instructions: #{cpu.instructions}"
    puts "Cycles: #{cpu.cycles}"
    puts "Simulated seconds: #{cpu.cycles.to_f / 1000}"
    puts
  end

end
