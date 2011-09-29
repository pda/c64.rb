#!env ruby
$LOAD_PATH.unshift "."
require "c64/cpu"

cpu = C64::Cpu.new

cpu.instance_variable_get(:@memory).tap do |m|
  m[0] = 0xEA # NOP
  m[1] = 0xA2 # LDX imm
  m[2] = 111  # arbitrary byte
  m[3] = 0xA0 # LDY imm
  m[4] = 222  # arbitrary byte
end

cpu.instance_variable_get(:@registers).tap do |r|
  r.pc = 0    # program counter
end

cpu.step
cpu.step
cpu.step
p cpu
