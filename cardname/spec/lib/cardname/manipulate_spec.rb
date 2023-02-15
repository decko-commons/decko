# encoding: utf-8

require_relative "../../spec_helper"

RSpec.describe Cardname::Manipulate do
  describe "#swap" do
    def swap str, change
      str.to_name.swap(*change.to_a.flatten).to_s
    end

    it "swaps first name part" do
      expect(swap("a+b", "a" => "x")).to eq("x+b")
    end

    it "swaps last name part" do
      expect(swap("a+b", "b" => "x")).to eq("a+x")
    end

    it "swaps middle name part" do
      expect(swap("a+c+b", "c" => "x")).to eq("a+x+b")
    end

    it "swaps all occurrences" do
      expect(swap("a+c+b+c+c", "c" => "x")).to eq("a+x+b+x+x")
    end

    it "swaps compound name" do
      expect(swap("a+b+c", "a+b" => "x")).to eq("x+c")
      expect(swap("a+b+c+d", "a+b" => "e+f")).to eq("e+f+c+d")
    end

    it "swaps two part trunk" do
      expect(swap("a+b+c", "a+b" => "x")).to eq("x+c")
    end

    it "swaps two part tag" do
      expect(swap("a+b+c", "b+c" => "x")).to eq("a+x")
    end

    it "swaps based on key match" do
      expect(swap("A+ b +C?", "a+b+c" => "x")).to eq("x")
    end

    it "swaps whole name" do
      expect(swap("a+b+c", "a+b+c" => "x")).to eq("x")
    end

    it "swaps with original format" do
      expect(swap("a+b", "a+B" => "X?+C")).to eq("X?+C")
    end
  end

  describe "#sub_in" do
    def sub old, new, str
      old.to_name.sub_in str, with: new
    end

    it "substitutes parts" do
      expect(sub("Ponies", "Camel", "pony farm Ponies")).to eq "camel farm Camels"
    end

    it "substitutes plural version" do
      expect(sub("Pony", "Camel", "ponies")).to eq "camels"
    end

    it "substitutes plural capital version" do
      expect(sub("Pony", "Camel", "Ponies")).to eq "Camels"
    end

    it "substitutes singular capital version" do
      expect(sub("ponies", "Camels", "Pony")).to eq "Camel"
    end
  end
end
