# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Search do
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
