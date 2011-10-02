require_relative "spec_helper"
require "c64/memory"
require "c64/data_types"

module C64
  describe Memory do

    def mem; Memory.new; end

    it "defaults to 64k" do
      Memory.new.size.must_equal 0x10000
    end

    it "can be created with custom size" do
      Memory.new(0x100).size.must_equal 0x100
    end

    it "can be written to and read from" do
      m = Memory.new
      m[1024] = 0x88
      m[1024].must_equal 0x88
    end

    it "can be accessed using Uint16" do
      Memory.new[Uint16.new(0)].must_equal 0
    end

    it "disallows read from negative address" do
      ->{ mem[-1] }.must_raise RuntimeError
    end

    it "disallows write to negative address" do
      ->{ mem[-1] = 0xFF }.must_raise RuntimeError
    end

    it "disallows read above bounds" do
      ->{ mem[mem.size] }.must_raise RuntimeError
    end

    it "disallows write above bounds" do
      ->{ mem[mem.size] = 0xFF }.must_raise RuntimeError
    end

    describe "uint8 bounds" do
      def must_store_x_as_y x, y
        Memory.new.tap do |m|
          m[0x12] = x
          m[0x12].must_equal y
        end
      end

      it "stores 0x100 as 0x00" do
        must_store_x_as_y 0x100, 0x00
      end
      it "stores 0x101 as 0x01" do
        must_store_x_as_y 0x101, 0x01
      end
      it "stores -1 as 0xFF" do
        must_store_x_as_y -1, 0xFF
      end
      it "decrements 0x00 by 3 to 0xFD" do
        Memory.new.tap do |m|
          m[0x12] = 0x00
          m[0x12] -= 3
          m[0x12].must_equal 0xFD
        end
      end
      it "increments 0xFF by 3 to 0x02" do
        Memory.new.tap do |m|
          m[0x12] = 0xFF
          m[0x12] += 3
          m[0x12].must_equal 0x02
        end
      end
    end

  end
end
