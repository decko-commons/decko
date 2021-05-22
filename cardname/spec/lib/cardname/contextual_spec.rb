# encoding: utf-8

require_relative "../../spec_helper"

RSpec.describe Cardname::Contextual do
  def expect_absolute name, context
    expect name.to_name.absolute(context)
  end

  def expect_from name, *from
    expect name.to_name.from(*from)
  end

  describe "#absolute" do
    it "handles _self, _whole, _" do
      expect_absolute("_self",  "foo").to eq("foo")
      expect_absolute("_whole", "foo").to eq("foo")
      expect_absolute("_",      "foo").to eq("foo")
    end

    it "handles _left" do
      expect_absolute("_left+Z", "A+B+C").to eq("A+B+Z")
    end

    it "handles white space" do
      expect_absolute("_left + Z", "A+B+C").to eq("A+B+Z")
    end

    it "handles _right" do
      expect_absolute("_right+bang", "nutter+butter").to eq("butter+bang")
      expect_absolute("C+_right", "B+A").to eq("C+A")
    end

    it "handles leading +" do
      expect_absolute("+bug", "hum").to eq("hum+bug")
    end

    it "handles trailing +" do
      expect_absolute("bug+", "tracks").to eq("bug+tracks")
    end

    it "handles leading + in context" do
      expect_absolute("+B", "+A").to eq("+A+B")
    end

    it "handles leading + in context for child" do
      expect_absolute("+A+B", "+A").to eq("+A+B")
    end

    it "handles _(numbers)" do
      expect_absolute("_1",    "A+B+C").to eq("A")
      expect_absolute("_1+_2", "A+B+C").to eq("A+B")
      expect_absolute("_2+_3", "A+B+C").to eq("B+C")
    end

    it "handles empty name" do
      expect("".to_name.absolute("A+B")).to eq("")
    end

    it "handles _LLR etc" do
      expect_absolute("_R", "A+B+C+D+E").to    eq("E")
      expect_absolute("_L", "A+B+C+D+E").to    eq("A+B+C+D")
      expect_absolute("_LR", "A+B+C+D+E").to   eq("D")
      expect_absolute("_LL", "A+B+C+D+E").to   eq("A+B+C")
      expect_absolute("_LLR", "A+B+C+D+E").to  eq("C")
      expect_absolute("_LLL", "A+B+C+D+E").to  eq("A+B")
      expect_absolute("_LLLR", "A+B+C+D+E").to eq("B")
      expect_absolute("_LLLL", "A+B+C+D+E").to eq("A")
    end

    context "with mismatched requests" do
      it "returns _self for _left or _right on simple cards" do
        expect_absolute("_left+Z", "A").to eq("A+Z")
        expect_absolute("_right+Z", "A").to eq("A+Z")
      end

      it "handles bogus numbers" do
        expect_absolute("_1", "A").to eq("A")
        expect_absolute("_1+_2", "A").to eq("A+A")
        expect_absolute("_2+_3", "A").to eq("A+A")
      end

      it "handles bogus _llr requests" do
        %w[_R _L _LR _LL _LLR _LLL _LLLR _LLLL].each do |variant|
          expect_absolute(variant, "A").to eq("A")
        end
      end
    end
  end

  describe "#from" do
    it "ignores ignorables" do
      expect_from("you+awe", "you").to eq("+awe")
      # expect("me+you+awe".to_name.from("you")).to eq("me+awe")
      # #HMMM..... what should this do?
      expect_from("me+you+awe", "me").to eq("+you+awe")
      expect_from("me+you+awe", "me", "you").to eq("+awe")
      expect_from("me+you", "me", "you").to eq("me+you")
      expect_from("?a?+awe", "A").to eq("+awe")
      expect_from("+awe").to eq("+awe")
      expect_from("+awe", nil).to eq("+awe")
    end
  end

  describe "#child_of?" do
    [["A+B",   "A",     true],
     ["A+B",   "B",     true],
     ["A+B+C", "A+B",   true],
     ["A+B+C", "C",     true],
     ["A+B",   "A+B",   false],
     ["A+B",   "A+B+C", false],
     ["A",     "A",     false],
     ["A+B+C",  "A",    false],
     ["A+C",   "A+B",   false],
     ["A+B",   "C+B",   false],
     ["X+A+B", "A+C",   false],
     ["+A", "B",         true],
     ["+A", "A",         true],
     ["+A", "+D",        true],
     ["+A", "+A",       false]].each do |a, b, res|
      it "#{a} is a child of #{b}" do
        expect(a.to_name.child_of?(b)).to be res
      end
    end
  end

  describe "#name_from" do
    [
      ["A+B",   "A",   "+B"],
      ["A+B",   "B",   "A+B"],
      %w[A A A],
      ["A+B",   "A+B", "A+B"],
      ["A",     "A+B", "A"]
      # ["A+C",   "A+B", "+C"],
      # ["A+B",   "C+B", "A"],
      # ["X+A+B", "A+C", "X+B"]
    ].each do |name, from, res|
      it "#{name} from #{from} is #{res}" do
        expect(name.to_name.from(from)).to eq res
      end
    end
  end
end
