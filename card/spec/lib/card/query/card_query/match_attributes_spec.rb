require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::MatchAttributes do
  include QuerySpecHelper

  # TODO: add specs for: #complete

  describe "match" do
    it "reachs content and name via shortcut" do
      expect(run_query(match: "two")).to eq(cards_matching_two)
    end

    it "gets only content when content is explicit" do
      expect(run_query(content: [:match, "two"])).to eq(["Joe User"])
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
end
