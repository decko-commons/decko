require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::FoundBy do
  include QuerySpecHelper

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
      image_cards = Card.search type: "Image", return: :name, sort_by: :name
      expect(run_query(found_by: "Image+*type+by name")).to eq(image_cards)
    end

    it "plays nicely with other properties and relationships" do
      expect(run_query(plus: { found_by: "Simple Search" }))
        .to eq(Card::Query.run(plus: { name: "A" }, return: :name, sort_by: :name))
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
