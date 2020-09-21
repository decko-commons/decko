require_relative "query_spec_helper"
RSpec.describe Card::Query::CardQuery do
  include QuerySpecHelper

  describe "basics" do
    it "is case insensitive for name" do
      expect(run_query(name: "a")).to eq(["A"])
    end

    it "returns count" do
      expect(Card.count_by_cql part: "A").to eq(7)
    end

    it "treats Symbols as Strings" do
      expect(run_query(codename: :account)).to eq(["*account"])
    end

    it "handles nil" do
      expect(run_query(name:"*account", codename: nil)).to eq([])
      expect(run_query(name:"A", codename: nil)).to eq(["A"])
    end

    it "handles not nil" do
      expect(run_query(name:"*account", codename: ["!", nil])).to eq(["*account"])
      expect(run_query(name:"A", codename: ["is not", nil])).to eq([])
    end
  end

  describe "in" do
    example "content option" do
      expect(run_query(in: %w(AlphaBeta Theta)).sort).to eq(%w(A+B T))
    end

    it "finds the same thing in full syntax" do
      expect(run_query(content: [:in, "Theta", "AlphaBeta"]).sort).to eq(%w(A+B T))
    end

    it "is the default conjunction for arrays" do
      expect(run_query(name: %w(C D F))).to eq(%w(C D F))
    end

    example "type option" do
      expect(run_query(type: [:in, "Cardtype E", "Cardtype F"]))
        .to eq(%w(type-e-card type-f-card))
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
      expect(run_query(content: ["=", "I'm number two"])).to eq(["Joe User"])
    end

    it "matchs via shortcut" do
      expect(run_query("=" => "I'm number two")).to eq(["Joe User"])
    end
  end
end
