require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::SpecialAttributes do
  include QuerySpecHelper

  # TODO: add specs for: #name_match, #complete, #junction_complete

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

  describe "found_by" do
    before do
      Card::Auth.as_bot do
        Card.create(name: "Simple Search", type: "Search", content: '{"name":"A"}')
      end
    end

    it "finds cards returned by search of given name" do
      expect(run_query(found_by: "Simple Search")).to eq(["A"])
    end

    it "finds cards returned by virtual cards" do
      image_cards = Card.search type: "Image", return: :name, sort: :name
      expect(run_query(found_by: "Image+*type+by name")).to eq(image_cards)
    end

    it "plays nicely with other properties and relationships" do
      expect(run_query(plus: { found_by: "Simple Search" }))
        .to eq(Card::Query.run(plus: { name: "A" }, return: :name, sort: :name))
    end

    it "plays work with virtual cards" do
      expect(run_query(found_by: "A+*self", plus: "C")).to eq(["A"])
    end

    it "is able to handle _self" do
      expect(run_query(context: "Simple Search", left: { found_by: "_self" },
                       right: "B", return: :name)).to eq(["A+B"])
    end
  end
end
