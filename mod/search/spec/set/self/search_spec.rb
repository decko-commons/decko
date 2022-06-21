# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Search do
  def card_subject
    :search.card
  end

  describe "#search_with_params" do
    context "with keyword" do
      def keyword_search value
        Card::Env.params[:query] = { keyword: value }
        Card[:search].format.search_with_params
      end

      it "processes cql" do
        expect(keyword_search('{"type":"user"}')).to include Card["Joe User"]
      end
    end
  end

  describe "view: search_box" do
    it "has a form" do
      expect_view(:search_box).to have_tag "form.search-box-form" do
        with_tag "select.search-box"
      end
    end

    it "has no errors" do
      expect_view(:search_box).to lack_errors
    end
  end
end
