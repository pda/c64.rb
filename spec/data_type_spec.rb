require_relative "spec_helper"
require "c64/data_types"

module C64

  describe Uint8 do
    it "compares equally to Fixnum" do
      Uint8.new(10).must_equal 10
    end

    it "comparse inequally to Fixnum" do
      (Uint8.new(10) == 20).must_equal false
    end

    it "compares greater than Fixnum" do
      (Uint8.new(8) > 4).must_equal true
    end

    it "compares less than Fixnum" do
      (Uint8.new(8) < 4).must_equal false
    end

    it "is stored mod 0x100" do
      Uint8.new(0x100 * 2 + 4).must_equal 4
    end

    it "stores -4 as 0xFC" do
      Uint8.new(-4).must_equal 0xFC
    end

    it "can be updated" do
      int = Uint8.new(0)
      int.update(0x100 + 4).must_equal 4
      int.must_equal 4
    end

    it "increments from 0 to 1" do
      (Uint8.new(0) + 1).must_equal 1
    end

    it "increments from 0xFF to 0" do
      (Uint8.new(0xFF) + 1).must_equal 0
    end

    it "decrements from 1 to 0" do
      (Uint8.new(1) - 1).must_equal 0
    end

    it "decrements from 0 to 0xFF" do
      (Uint8.new(0) - 1).must_equal 0xFF
    end

    it "exposes bytes" do
      Uint8.new(0xDD).bytes.must_equal [ 0xDD ]
    end

    it "does not respond to #high or #low" do
      uint8 = Uint8.new(0)
      uint8.respond_to?(:high).must_equal false
      uint8.respond_to?(:low).must_equal false
    end

    it "is inspectable" do
      Uint8.new(32).inspect.must_equal "#<C64::Uint8(32)>"
    end

    it "unpacks from String" do
      Uint8.unpack("\xAA").must_equal 0xAA
    end
  end

  describe Uint16 do
    it "is stored mod 0x10000" do
      Uint16.new(0x10000 * 2 + 4).must_equal 4
    end

    it "stores -4 as 0xFFFC" do
      Uint16.new(-4).must_equal 0xFFFC
    end

    it "increments from 0xFFFF to 0" do
      (Uint16.new(0xFFFF) + 1).must_equal 0
    end

    it "decrements from 0 to 0xFFFF" do
      (Uint16.new(0) - 1).must_equal 0xFFFF
    end

    it "exposes bytes" do
      Uint16.new(0xDDEE).bytes.must_equal [ 0xEE, 0xDD ]
    end

    it "exposes high byte" do
      Uint16.new(0xDDEE).high.must_equal 0xDD
    end

    it "exposes low byte" do
      Uint16.new(0xDDEE).low.must_equal 0xEE
    end

    it "assigns high byte" do
      Uint16.new(0xDDEE).tap do |i|
        i.high = 0xAA
      end.must_equal 0xAAEE
    end

    it "assigns low byte" do
      Uint16.new(0xDDEE).tap do |i|
        i.low = 0xAA
      end.must_equal 0xDDAA
    end

    it "unpacks from String" do
      Uint16.unpack("\xAA\xBB").must_equal 0xBBAA
    end
  end

end
