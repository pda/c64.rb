require_relative "spec_helper"
require "c64/memory"

module C64
  describe Memory do

    def mem; Memory.new; end

    it "can be written to and read from" do
      m = Memory.new
      m[1024] = 0x88
      m[1024].must_equal 0x88
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
      ->{ mem[mem.size] }.must_raise RuntimeError
    end

  end
end
