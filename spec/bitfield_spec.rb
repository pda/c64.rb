require_relative "spec_helper"
require "c64/bitfield"

module C64
  describe Bitfield do

    describe "with two fields, initialized as zero" do
      let(:bf) { Bitfield.new(:a, :b).new(0) }
      it "answers zero to to_i" do
        bf.to_i.must_equal 0
      end
      it "answers false to predicates" do
        bf.a?.must_equal false
        bf.b?.must_equal false
      end
      it "answers zero to readers" do
        bf.a.must_equal 0
        bf.b.must_equal 0
      end
      it "writes first bit" do
        bf.a = 1
        bf.a.must_equal 1
        bf.to_i.must_equal 1
      end
      it "writes second bit" do
        bf.b = 1
        bf.b.must_equal 1
        bf.to_i.must_equal 2
      end
      it "raises NoMethodError for unknown predicates" do
        ->{ bf.c? }.must_raise NoMethodError
      end
      it "raises NoMethodError for unknown readers" do
        ->{ bf.c }.must_raise NoMethodError
      end
    end

    describe "with two fields, initialized with 0b10" do
      let(:bf) { Bitfield.new(:a, :b).new(0b10) }
      it "answers predicates correctly" do
        bf.a?.must_equal false
        bf.b?.must_equal true
      end
      it "answers readers correctly" do
        bf.a.must_equal 0
        bf.b.must_equal 1
      end
      it "can be inspected" do
        bf.inspect.must_equal "Bitfield(a:0 b:1)"
      end
    end

  end
end
