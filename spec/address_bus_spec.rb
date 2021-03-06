require_relative "spec_helper"
require "c64/address_bus"

module C64
  describe AddressBus do

    let(:ram) { MiniTest::Mock.new }
    let(:kernal) { MiniTest::Mock.new }
    let(:basic) { MiniTest::Mock.new }
    let(:char) { MiniTest::Mock.new }
    let(:io) { MiniTest::Mock.new }
    let(:banks) { { ram: ram, kernal: kernal, basic: basic, char: char, io: io } }
    let(:bus) { AddressBus.new banks }

    def self.it_addresses address, parameters
      at = parameters[:at] || address
      if bank = parameters[:accesses]
        parameters[:reads], parameters[:writes] = bank, bank
      end
      if bank = parameters[:reads]
        it "reads 0x#{"%4X" % address} from #{bank} at 0x#{"%04X" % at}" do
          bank = banks[parameters[:reads]]
          bank.expect :[], 0xAA, [at]
          bus[address].must_equal 0xAA
          bank.verify
        end
      end
      if bank = parameters[:writes]
        it "writes 0x#{"%04X" % address} to #{bank} at 0x#{"%04X" % at}" do
          bank = banks[parameters[:writes]]
          bank.expect :[]=, nil, [at, 0xBB]
          bus[address] = 0xBB
          bank.verify
        end
      end
    end

    it "raises OutOfBounds for addresses over 0xFFFF" do
      ->{ bus[0x10000] }.must_raise AddressBus::OutOfBounds
    end

    describe "with control flags set zero" do
      before { bus[0x0001] = 0x00 }
      it_addresses 0xA000, accesses: :ram
      it_addresses 0xD008, reads: :char, at: 0x0008
      it_addresses 0xD008, writes: :ram
      it_addresses 0xE000, accesses: :ram
    end

    describe "with control flags set 0b00000111" do
      before { bus[0x0001] = 0b00000111 }
      it_addresses 0xA008, reads: :basic, at: 0x0008
      it_addresses 0xA008, writes: :ram
      it_addresses 0xD008, accesses: :io, at: 0x0008
      it_addresses 0xE008, reads: :kernal, at: 0x0008
      it_addresses 0xE008, writes: :ram
    end

  end
end
