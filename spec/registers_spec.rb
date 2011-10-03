require_relative "spec_helper"
require "c64/registers"

module C64
  describe Registers do

    describe "#pc" do
      it "increments from 0 to 1" do
        Registers.new(0, 0, 0, 0, 0, 0).tap do |r|
          r.pc += 1
          r.pc.must_equal 1
        end
      end
      it "increments from 0xFFFF to 0x0000" do
        Registers.new(0xFFFF, 0, 0, 0, 0, 0).tap do |r|
          r.pc += 1
          r.pc.must_equal 0
        end
      end
    end

    describe "#sp" do
      it "applies mod 0x100 on initialization" do
        Registers.new(0, 0, 0, 0, 0, 0x100).sp.must_equal 0
      end
    end

    describe "#status" do
      def status status
        Registers.new(0, 0, 0, 0, status, 0).status
      end

      describe "for 0b00000000" do
        it "answers false for all flags" do
          status(0b00000000).tap do |s|
            s.negative?.must_equal false
            s.overflow?.must_equal false
            s.break?.must_equal false
            s.decimal?.must_equal false
            s.interrupt?.must_equal false
            s.zero?.must_equal false
            s.carry?.must_equal false
          end
        end
      end

      it "is negative? for 0b10000000" do
        status(0b10000000).negative?.must_equal true
      end
      it "is overflow? for 0b01000000" do
        status(0b01000000).overflow?.must_equal true
      end
      it "is break? for 0b00010000" do
        status(0b00010000).break?.must_equal true
      end
      it "is decimal? for 0b00001000" do
        status(0b00001000).decimal?.must_equal true
      end
      it "is interrupt? for 0b00000100" do
        status(0b00000100).interrupt?.must_equal true
      end
      it "is zero? for 0b00000010" do
        status(0b00000010).zero?.must_equal true
      end
      it "is carry? for 0b00000001" do
        status(0b00000001).carry?.must_equal true
      end

      it "can set and unset zero? flag" do
        r = Registers.new(0, 0, 0, 0, 0b01010101, 0)
        r.status.zero?.must_equal false
        r.status.zero = true
        r.status.zero?.must_equal true
        r.status.zero = false
        r.status.zero?.must_equal false
        r.status.to_i.must_equal 0b01010101
      end

      it "can set and unset carry? flag using 0 and 1" do
        r = Registers.new(0, 0, 0, 0, 0b01010100, 0)
        r.status.carry?.must_equal false
        r.status.carry = 1
        r.status.carry?.must_equal true
        r.status.carry = 0
        r.status.carry?.must_equal false
        r.status.to_i.must_equal 0b01010100
      end

    end
  end
end
