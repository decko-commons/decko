require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Conjunctions do
  include QuerySpecHelper

  describe "and" do
    it "acts as a simple passthrough with operators" do
      @query = { and: { match: "two" } }
      is_expected.to eq(cards_matching_two)
    end

    it "acts as a simple passthrough with relationships" do
      @query = { and: {}, type: "Cardtype E" }
      is_expected.to eq(["type-e-card"])
    end

    it 'works within "or"' do
      @query = { or: { name: "Z", and: { left: "A", right: "C" } } }
      is_expected.to eq(["A+C", "Z"])
    end
  end

  describe "any" do
    it "works with :plus" do
      @query = { plus: "A", any: { name: "B", match: "K" } }
      is_expected.to eq(["B"])
    end

    it "works with multiple plusses" do
      @query = { or: { right_plus: "A", plus: "B" } }
      is_expected.to eq(%w(A C D F))
    end
  end

  describe "not" do
    it "excludes cards matching not criteria" do
      Card::Auth.as_bot
      @query = { plus: "A", not: { plus: "A+B" } }
      is_expected.to eq(%w(B D E F))
    end
  end

  # the following are higher level queries that generally involve conjunctions.
  # not sure this should be their permanent home...

  describe "multiple values" do
    it "handles :all as the first element of an Array" do
      @query = { member_of: [:all, { name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2))
    end

    it "handles act like :all by default" do
      @query = { member_of: [{ name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2))
    end

    it "handles :any as the first element of an Array" do
      @query = { member_of: [:any, { name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2 u3))
    end

    it "handles :any as a relationship" do
      @query = { member_of: { any: [{ name: "r1" }, { key: "r2" }] } }
      is_expected.to eq(%w(u1 u2 u3))
    end

    it "handles explicit conjunctions in plus_relational keys" do
      @query = { right_plus: [:all, "e", "c"] }
      is_expected.to eq(%w(A))
    end

    it "handles multiple values for right_part in compound relations" do
      @query = { right_plus: [["e", {}], "c"] }
      is_expected.to eq(%w(A)) # first element is array
    end

    it "does not interpret simple arrays as multi values for plus" do
      @query = { right_plus: %w(e c) }
      is_expected.to eq([]) # NOT interpreted as multi-value
    end

    it "handles :and for references" do
      @query = { refer_to: [:and, "a", "b"] }
      is_expected.to eq(%w(Y))
    end

    it "handles :or for references" do
      @query = { refer_to: [:or, "b", "z"] }
      is_expected.to eq(%w(A B Y))
    end

    it "handles treat simple arrays like :all for references" do
      @query = { refer_to: %w(A T) }
      is_expected.to eq(%w(X Y))
    end
  end
end
