# encoding: utf-8
require_relative "../../spec_helper"

RSpec.describe Cardname::Contextual do
  describe "#absolute" do
    it "handles _self, _whole, _" do
      expect("_self".to_name.absolute("foo")).to eq("foo")
      expect("_whole".to_name.absolute("foo")).to eq("foo")
      expect("_".to_name.absolute("foo")).to eq("foo")
    end

    it "handles _left" do
      expect("_left+Z".to_name.absolute("A+B+C")).to eq("A+B+Z")
    end

    it "handles white space" do
      expect("_left + Z".to_name.absolute("A+B+C")).to eq("A+B+Z")
    end

    it "handles _right" do
      expect("_right+bang".to_name.absolute("nutter+butter")).to eq("butter+bang")
      expect("C+_right".to_name.absolute("B+A")).to eq("C+A")
    end

    it "handles leading +" do
      expect("+bug".to_name.absolute("hum")).to eq("hum+bug")
    end

    it "handles trailing +" do
      expect("bug+".to_name.absolute("tracks")).to eq("bug+tracks")
    end

    it "handles leading + in context" do
      expect("+B".to_name.absolute("+A")).to eq("+A+B")
    end

    it "handles leading + in context for child" do
      expect("+A+B".to_name.absolute("+A")).to eq("+A+B")
    end

    it "handles _(numbers)" do
      expect("_1".to_name.absolute("A+B+C")).to eq("A")
      expect("_1+_2".to_name.absolute("A+B+C")).to eq("A+B")
      expect("_2+_3".to_name.absolute("A+B+C")).to eq("B+C")
    end

    it "handles empty name" do
      expect("".to_name.absolute("A+B")).to eq("")
    end

    it "handles _LLR etc" do
      expect("_R".to_name.absolute("A+B+C+D+E")).to    eq("E")
      expect("_L".to_name.absolute("A+B+C+D+E")).to    eq("A+B+C+D")
      expect("_LR".to_name.absolute("A+B+C+D+E")).to   eq("D")
      expect("_LL".to_name.absolute("A+B+C+D+E")).to   eq("A+B+C")
      expect("_LLR".to_name.absolute("A+B+C+D+E")).to  eq("C")
      expect("_LLL".to_name.absolute("A+B+C+D+E")).to  eq("A+B")
      expect("_LLLR".to_name.absolute("A+B+C+D+E")).to eq("B")
      expect("_LLLL".to_name.absolute("A+B+C+D+E")).to eq("A")
    end

    context "mismatched requests" do
      it "returns _self for _left or _right on simple cards" do
        expect("_left+Z".to_name.absolute("A")).to eq("A+Z")
        expect("_right+Z".to_name.absolute("A")).to eq("A+Z")
      end

      it "handles bogus numbers" do
        expect("_1".to_name.absolute("A")).to eq("A")
        expect("_1+_2".to_name.absolute("A")).to eq("A+A")
        expect("_2+_3".to_name.absolute("A")).to eq("A+A")
      end

      it "handles bogus _llr requests" do
        expect("_R".to_name.absolute("A")).to eq("A")
        expect("_L".to_name.absolute("A")).to eq("A")
        expect("_LR".to_name.absolute("A")).to eq("A")
        expect("_LL".to_name.absolute("A")).to eq("A")
        expect("_LLR".to_name.absolute("A")).to eq("A")
        expect("_LLL".to_name.absolute("A")).to eq("A")
        expect("_LLLR".to_name.absolute("A")).to eq("A")
        expect("_LLLL".to_name.absolute("A")).to eq("A")
      end
    end
  end

  describe "#from" do
    it "ignores ignorables" do
      expect("you+awe".to_name.from("you")).to eq("+awe")
      #expect("me+you+awe".to_name.from("you")).to eq("me+awe") #HMMM..... what should this do?
      expect("me+you+awe".to_name.from("me" )).to eq("+you+awe")
      expect("me+you+awe".to_name.from("me","you")).to eq("+awe")
      expect("me+you".to_name.from("me","you")).to eq("me+you")
      expect("?a?+awe".to_name.from("A")).to eq("+awe")
      expect("+awe".to_name.from()).to eq("+awe")
      expect("+awe".to_name.from(nil)).to eq("+awe")
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
     ["A",     "A",   "A"],
     ["A+B",   "A+B", "A+B"],
     ["A",     "A+B", "A"],
     #["A+C",   "A+B", "+C"],
     #["A+B",   "C+B", "A"],
     #["X+A+B", "A+C", "X+B"]
    ].each do |name, from, res|
      it "#{name} from #{from} is #{res}" do
        expect(name.to_name.from from).to eq res
      end
    end
  end

end
