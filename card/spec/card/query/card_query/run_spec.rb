require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Run do
  include QuerySpecHelper

  it "does not alter original statement" do
    query = { right_plus: { name: %w[in tag source] } }
    query_clone = query.deep_clone
    Card::Query.run query
    expect(query_clone).to eq(query)
  end

  describe "alter_result (append)" do
    context "when returning names" do
      it "finds real cards" do
        expect(run_query(name: [:in, "C", "D", "F"], append: "A"))
          .to eq(%w[C+A D+A F+A])
      end

      it "absolutizes names" do
        expect(run_query(name: [:in, "C", "D", "F"], append: "_right", context: "B+A"))
          .to eq(%w[C+A D+A F+A])
      end

      it "finds virtual cards" do
        expect(run_query(name: [:in, "C", "D"], append: "*plus cards"))
          .to eq(["C+*plus cards", "D+*plus cards"])
      end
    end

    context "when returning cards" do
      it "appends name to card results" do
        res = Card::Query.run name: [:in, "C", "D", "F"], append: "A"
        expect(res).to contain_exactly(Card["C+A"], Card["D+A"], Card["F+A"])
      end

      it "instantiates unknown card" do
        res = Card::Query.run name: "Z", append: "A"
        expect(res.first).to be_a_new_card.and have_name "Z+A"
      end
    end
  end

  describe "process_name (relative return value)" do
    def returning field
      # before results are altered, this returns `A+B+C` and `A+C`
      Card::Query.run right: "C", return: field, sort_by: :id
    end

    it "handles _left" do
      expect(returning("_left")).to eq %w[A A+B]
    end

    it "handles _right" do
      expect(returning("_right")).to eq %w[C C]
    end

    it "handles _LL" do
      expect(returning("_LL")).to eq %w[A+C A]
    end
  end
end
