require_relative "spec_helper"
require "c64/registers"

module C64
  describe Registers do
    describe "#status" do
      def status status
        Registers.new(nil, nil, nil, nil, status, nil).status
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
        s = status(0b01010101)
        s.zero = true
        s.zero?.must_equal true
        s.zero = false
        s.zero?.must_equal false
        s.to_i.must_equal 0b01010101
      end

    end
  end
end
