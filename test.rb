#!env ruby
$LOAD_PATH.unshift "."
require "c64/cpu"
require "c64/memory"
require "c64/address_bus"

module C64

  # TODO: why is BASIC not being read?
  # TODO: check implied (+indexed) addressing.. carry?

  memory = AddressBus.new \
    ram: Memory.new(0x10000, tag: nil), # 64k
    kernal: Memory.new(0x2000, image: "rom/kernal.rom"), # 8k
    basic: Memory.new(0x2000, image: "rom/basic.rom", tag: "BASIC"), # 8k
    char: Memory.new(0x1000, image: "rom/character.rom", tag: "CHAR"), # 4k
    io: Memory.new(0x1000, tag: nil) # 4k

  memory[0x0000] = 0b101111 # directions, 0:in, 1:out
  memory[0x0001] = 0b000111 # data

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
