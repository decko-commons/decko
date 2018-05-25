require_relative "query_spec_helper"
RSpec.describe Card::Query::CardQuery do
  include QuerySpecHelper

  describe "basics" do
    it "is case insensitive for name" do
      @query = { name: "a" }
      is_expected.to eq(["A"])
    end

    it "returns count" do
      expect(Card.count_by_wql part: "A").to eq(7)
    end
  end

  describe "in" do
    example "content option" do
      @query = { in: %w(AlphaBeta Theta) }
      is_expected.to eq(%w(A+B T))
    end

    it "finds the same thing in full syntax" do
      @query = { content: [:in, "Theta", "AlphaBeta"] }
      is_expected.to eq(%w(A+B T))
    end

    it "is the default conjunction for arrays" do
      @query = { name: %w(C D F) }
      is_expected.to eq(%w(C D F))
    end

    example "type option" do
      @query = { type: [:in, "Cardtype E", "Cardtype F"] }
      is_expected.to eq(%w(type-e-card type-f-card))
    end
  end

  describe "search count" do
    it "returns integer" do
      search = Card.create!(
          name: "tmpsearch",
          type: "Search",
          content: '{"match":"two"}'
      )
      expect(search.count).to eq(cards_matching_two.length + 1)
    end
  end

  describe "content equality" do
    it "matchs content explicitly" do
      @query = { content: ["=", "I'm number two"] }
      is_expected.to eq(["Joe User"])
    end

    it "matchs via shortcut" do
      @query = { "=" => "I'm number two" }
      is_expected.to eq(["Joe User"])
    end
  end
end
