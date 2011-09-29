require_relative "spec_helper"
require "c64/instruction_decoder"

module C64
  describe InstructionDecoder do

    def decoder
      InstructionDecoder.new
    end

    it "instantiates" do
      decoder.must_be_instance_of InstructionDecoder
    end

    it "decodes 0xEA to NOP" do
      decoder.decode(0xEA).tap do |i|
        i.name.must_equal :NOP
        i.addressing.must_equal :implied
        i.bytes.must_equal 1
        i.cycles.must_equal 2
        i.flags.must_be_nil
      end
    end

  end
end
