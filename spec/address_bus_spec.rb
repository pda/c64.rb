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
      if bank = parameters[:reads]
        it "reads 0x#{"%4X" % address} from #{bank} at 0x#{"%04X" % at}" do
          banks[parameters[:reads]].expect :[], 0xAA, [at]
          bus[address].must_equal 0xAA
        end
      end
      if bank = parameters[:writes]
        it "writes 0x#{"%04X" % address} to #{bank} at 0x#{"%04X" % at}" do
          banks[parameters[:writes]].expect :[]=, nil, [at, 0xBB]
          bus[address] = 0xBB
        end
      end
    end

    describe "with control flags set zero" do
      before { bus[0x0001] = 0x00 }
      it_addresses 0xA000, reads: :ram
      it_addresses 0xA000, writes: :ram
      it_addresses 0xD000, reads: :char, at: 0x0000
      it_addresses 0xD000, writes: :ram
      it_addresses 0xE000, reads: :ram
      it_addresses 0xE000, writes: :ram
    end

    describe "with control flags set 0b00000111" do
      before { bus[0x0001] = 0b00000111 }
      it_addresses 0xA000, reads: :basic, at: 0x0000
      it_addresses 0xA000, writes: :ram
      it_addresses 0xD000, reads: :io, at: 0x0000
      it_addresses 0xD000, writes: :io, at: 0x0000
      it_addresses 0xE000, reads: :kernal, at: 0x0000
      it_addresses 0xE000, writes: :ram
    end

  end
end
