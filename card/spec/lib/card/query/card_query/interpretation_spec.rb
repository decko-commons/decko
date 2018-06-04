require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Interpretation do
  include QuerySpecHelper

  describe "vars" do
    it "replace placeholders" do
      expect(run_query(match: "$keyword", vars: { keyword: "two" }))
        .to eq(cards_matching_two)
    end

    it "replace placeholders in nested queries" do
      expect(run_query(and: { match: "$keyword" }, vars: { keyword: "two" }))
        .to eq(cards_matching_two)
    end
  end
end
