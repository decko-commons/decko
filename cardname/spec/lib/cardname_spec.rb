# encoding: utf-8
require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Cardname do
  describe "#key" do
    it "lowercases and underscores" do
      expect("This Name".to_name.key).to eq("this_name")
    end

    it "removes spaces" do
      expect("this    Name".to_name.key).to eq("this_name")
    end

    describe "underscores" do
      it "is treated like spaces" do
        expect("weird_ combo".to_name.key).to eq("weird  combo".to_name.key)
      end

      it "does not impede pluralization checks" do
        expect("Mamas_and_Papas".to_name.key).to(
          eq("Mamas and Papas".to_name.key)
        )
      end

      it "is removed when before first word character" do
        expect("_This Name".to_name.key).to eq("this_name")
      end
    end

    it "singularizes" do
      expect("ethans".to_name.key).to eq("ethan")
    end

    it "changes CamelCase to snake case" do
      expect("ThisThing".to_name.key).to eq("this_thing")
    end

    it "handles plus cards" do
      expect("ThisThing+Ethans".to_name.key).to eq("this_thing+ethan")
    end

    it "retains * for star cards" do
      expect("*right".to_name.key).to eq("*right")
    end

    it "does not singularize double s's" do
      expect("grass".to_name.key).to eq("grass")
    end

    it "does not singularize letter 'S'" do
      expect("S".to_name.key).to eq("s")
    end

    it "handles unicode characters" do
      expect("Mañana".to_name.key).to eq("mañana")
    end

    it "handles weird initial characters" do
      expect("__you motha @\#$".to_name.key).to eq("you_motha")
      expect("?!_you motha @\#$".to_name.key).to eq("you_motha")
    end

    it "allows numbers" do
      expect("3way".to_name.key).to eq("3way")
    end

    it "internal plurals" do
      expect("cards hooks label foos".to_name.key).to eq("card_hook_label_foo")
    end

    it "handles html entities" do
      # This no longer takes off the s, is singularize broken now?
      expect("Jean-fran&ccedil;ois Noubel".to_name.key).to(
        eq("jean_françoi_noubel")
      )
    end
  end

  describe "unstable keys" do
    context "stabilize" do
      before do
        name_class = "".to_name.class
        name_class.stabilize = true
        name_class.reset_cache
      end
      it "should uninflect until key is stable" do
        expect("matthias".to_name.key).to eq("matthium")
      end
    end

    context "do not stabilize" do
      before do
        name_class = "".to_name.class
        name_class.stabilize = false
        name_class.reset_cache
      end
      it "should not uninflect unstable names" do
        expect("ilias".to_name.key).to eq("ilias")
      end
    end
  end

  describe "#valid" do
    it "accepts valid names" do
      expect("this+THAT".to_name).to be_valid
      expect("THE*ONE*AND$!ONLY".to_name).to be_valid
    end

    it "accepts escaped invalid characters" do
      expect("this/THAT".to_name).to be_valid
    end
  end

  describe "#include?" do
    context "A+B+C" do
      let(:name) { "A+B+CD+EF".to_name }
      it 'includes "A"' do
        expect(name.include? ("A")).to be_truthy
      end
      it '"includes "a"' do
        expect(name.include? ("a")).to be_truthy
      end
      it '"includes "B"' do
        expect(name.include? ("B")).to be_truthy
      end
      it '"includes "A+B"' do
        expect(name.include? ("A+B")).to be_truthy
      end
      it '"includes "CD+EF"' do
        expect(name.include? ("CD+EF")).to be_truthy
      end
      it '"includes "A+B+CD+EF"' do
        expect(name.include? ("A+B+CD+EF")).to be_truthy
      end
      it '"does not include "A+B+C"' do
        expect(name.include? ("A+B+C")).to be_falsey
      end
      it '"does not include "F"' do
        expect(name.include? ("F")).to be_falsey
      end
      it '"does not include "D+EF"' do
        expect(name.include? ("AD+EF")).to be_falsey
      end
    end
  end

  describe "dangerous methods" do
    RSpec::Matchers.define :have_attributes do |expected|
      match do |obj|
        expected.all? do |method, val|
          obj.send(method) == val
        end
      end
    end

    def name_with_cached_props str
      str.to_name.tap do |name|
        name.key
        name.parts
      end
    end

    def expect_changed_props args
      aggregate_failures do
        args.each do |method, val|
          expect(name.send(method)).to eq val
        end
      end
    end

    example "#replace update key and parts" do
      name = name_with_cached_props "A"
      name.replace("B")
      expect(name).to have_attributes key: "b", parts: ["B"]
    end

    example "#gsub! update key and parts" do
      name = name_with_cached_props "AxxA"
      name.gsub!("xx", "B")
      expect(name).to have_attributes key: "aba", parts: ["ABA"]
    end

    example "#next! updates key and parts" do
      name = name_with_cached_props "abc1"
      name.next!
      expect(name).to have_attributes key: "abc2", parts: ["abc2"]
    end
  end
end
