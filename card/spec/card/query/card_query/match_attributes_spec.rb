require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::MatchAttributes do
  include QuerySpecHelper

  describe "match" do
    it "reaches content and name via shortcut" do
      expect(run_query(match: "two")).to eq(cards_matching_two)
    end

    it "gets only content when content is explicit" do
      expect(run_query(content: [:match, "two"])).to eq(["42", "Joe User"])
    end

    it "gets only name when name is explicit" do
      expect(run_query(name: [:match, "two"])).to eq(["Two"])
    end

    context "with keyword" do
      it "escapes nonword characters" do
        expect(run_query(match: "*all")).to include("*all")
      end

      it "works like a regexp when prefixed by '~~'" do
        expect(run_query(match: "~~(two|three)").sort)
          .to eq((cards_matching_two + %w[Three]).sort)
      end

      it "ignores initial (single) '~'" do
        expect(run_query(match: "~two")).to eq(cards_matching_two)
      end
    end
  end

  describe "complete" do
    it "returns no plus cards when value has no plus" do
      expect(run_query(complete: "Any", sort_by: :name))
        .to eq(["Anyone", "Anyone Signed In"])
    end

    it "returns plus cards when value has plus" do
      expect(run_query(complete: "Anyone+", sort_by: :name))
        .to eq(["Anyone+description"])
    end
  end

  describe "name_match" do
    it "same as name: [:match, val]" do
      expect(run_query(name_match: "Any", sort_by: :name))
        .to eq(["Anyone", "Anyone Signed In"])
    end
  end
end
