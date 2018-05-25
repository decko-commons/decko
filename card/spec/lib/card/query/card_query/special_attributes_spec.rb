require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::SpecialAttributes do
  include QuerySpecHelper

  # TODO: add specs for: #name_match, #complete, #junction_complete

  describe "match" do
    it "reachs content and name via shortcut" do
      @query = { match: "two" }
      is_expected.to eq(cards_matching_two)
    end

    it "gets only content when content is explicit" do
      @query = { content: [:match, "two"] }
      is_expected.to eq(["Joe User"])
    end

    it "gets only name when name is explicit" do
      @query = { name: [:match, "two"] }
      is_expected.to eq(["One+Two", "One+Two+Three", "Two"])
    end

    context "with keyword" do
      it "escapes nonword characters" do
        @query = { match: "two :(!" }
        is_expected.to eq(cards_matching_two)
      end

      it "it can handle *" do
        @query = { match: "*all" }
        is_expected.to include("*all")
      end
    end
  end

  describe "found_by" do
    before do
      Card::Auth.as_bot
      Card.create(
          name: "Simple Search", type: "Search", content: '{"name":"A"}'
      )
    end

    it "finds cards returned by search of given name" do
      @query = { found_by: "Simple Search" }
      is_expected.to eq(["A"])
    end

    it "finds cards returned by virtual cards" do
      image_cards = Card.search type: "Image", return: :name, sort: :name
      @query = { found_by: "Image+*type+by name" }
      is_expected.to eq(image_cards)
    end

    it "plays nicely with other properties and relationships" do
      explicit_query = { plus: { name: "A" }, return: :name, sort: :name }
      @query = { plus: { found_by: "Simple Search" } }
      is_expected.to eq(Card::Query.run(explicit_query))
    end

    it "plays work with virtual cards" do
      @query = { found_by: "A+*self", plus: "C" }
      is_expected.to eq(["A"])
    end

    it "is able to handle _self" do
      @query = {
        context: "Simple Search",
        left: { found_by: "_self" },
        right: "B",
        return: :name
      }
      is_expected.to eq(["A+B"])
    end
  end
end
