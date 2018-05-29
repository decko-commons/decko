require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Conjunctions do
  include QuerySpecHelper

  describe "and" do
    it "acts as a simple passthrough with operators" do
      expect(run_query(and: { match: "two" })).to eq(cards_matching_two)
    end

    it "acts as a simple passthrough with relationships" do
      expect(run_query(and: {}, type: "Cardtype E")).to eq(["type-e-card"])
    end

    it 'works within "or"' do
      expect(run_query(or: { name: "Z", and: { left: "A", right: "C" } }))
        .to eq(["A+C", "Z"])
    end
  end

  describe "any" do
    it "works with :plus" do
      expect(run_query(plus: "A", any: { name: "B", match: "K" })).to eq(["B"])
    end

    it "works with multiple plusses" do
      expect(run_query(or: { right_plus: "A", plus: "B" })).to eq(%w(A C D F))
    end
  end

  describe "not" do
    it "excludes cards matching not criteria", as_bot: true do
      expect(run_query(plus: "A", not: { plus: "A+B" })).to eq(%w(B D E F))
    end
  end

  # the following are higher level queries that generally involve conjunctions.
  # not sure this should be their permanent home...

  describe "multiple values" do
    it "handles :all as the first element of an Array" do
      expect(run_query(member_of: [:all, { name: "r1" }, { key: "r2" }]))
        .to eq(%w(u1 u2))
    end

    it "handles act like :all by default" do
      expect(run_query(member_of: [{ name: "r1" }, { key: "r2" }]))
        .to eq(%w(u1 u2))
    end

    it "handles :any as the first element of an Array" do
      expect(run_query(member_of: [:any, { name: "r1" }, { key: "r2" }]))
        .to eq(%w(u1 u2 u3))
    end

    it "handles :any as a relationship" do
      expect(run_query(member_of: { any: [{ name: "r1" }, { key: "r2" }] }))
        .to eq(%w(u1 u2 u3))
    end

    it "handles explicit conjunctions in plus_relational keys" do
      expect(run_query(right_plus: [:all, "e", "c"])).to eq(%w(A))
    end

    it "handles multiple values for right_part in compound relations" do
      # note: first element is array
      expect(run_query(right_plus: [["e", {}], "c"])).to eq(%w(A))
    end

    it "does not interpret simple arrays as multi values for plus" do
      # NOT interpreted as multi-value
      expect(run_query(right_plus: %w(e c))).to eq([])
    end

    it "handles :and for references" do
      expect(run_query(refer_to: [:and, "a", "b"])).to eq(%w(Y))
    end

    it "handles :or for references" do
      expect(run_query(refer_to: [:or, "b", "z"])).to eq(%w(A B Y))
    end

    it "handles treat simple arrays like :all for references" do
      expect(run_query(refer_to: %w(A T))).to eq(%w(X Y))
    end
  end
end
