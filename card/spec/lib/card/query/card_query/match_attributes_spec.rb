require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::MatchAttributes do
  include QuerySpecHelper

  # TODO: add specs for: #complete

  describe "match" do
    it "reaches content and name via shortcut" do
      expect(run_query(match: "two")).to eq(cards_matching_two)
    end

    it "gets only content when content is explicit" do
      expect(run_query(content: [:match, "two"])).to eq(["42", "Joe User"])
    end

    it "gets only name when name is explicit" do
      expect(run_query(name: [:match, "two"])).to eq(["One+Two", "One+Two+Three", "Two"])
    end

    context "with keyword" do
      it "escapes nonword characters" do
        expect(run_query(match: "two :(!")).to eq(cards_matching_two)
      end

      it "it can handle *" do
        expect(run_query(match: "*all")).to include("*all")
      end
    end
  end

  describe "complete" do
    it "returns no plus cards when value has no plus" do
      expect(run_query(complete: "Any", sort: :name))
        .to eq(["Anyone", "Anyone Signed In", "Anyone With Role"])
    end

    it "returns plus cards when value has plus" do
      expect(run_query(complete: "Anyone+", sort: :name))
        .to eq(["Anyone+description"])
    end
  end

  describe "name_match" do
    it "matches names with or without plusses" do
      expect(run_query(name_match: "Any", sort: :name))
        .to eq(["Anyone", "Anyone+description", "Anyone Signed In", "Anyone Signed In+dashboard", "Anyone Signed In+description", "Anyone With Role"])
    end
  end
end
