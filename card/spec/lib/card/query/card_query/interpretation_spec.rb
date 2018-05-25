require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Interpretation do
  include QuerySpecHelper

  describe "vars" do
    it "replace placeholders" do
      @query = { match: "$keyword", vars: { keyword: "two" } }
      is_expected.to eq(cards_matching_two)
    end

    it "replace placeholders in nested queries" do
      @query = { and: { match: "$keyword" }, vars: { keyword: "two" } }
      is_expected.to eq(cards_matching_two)
    end
  end
end
