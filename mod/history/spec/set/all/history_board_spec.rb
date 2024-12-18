# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::HistoryBoard do
  describe "view: updated_by" do
    it "is blank if no updates after create" do
      expect(format_subject.render_updated_by).not_to be_match(/Joe/)
    end

    it "includes users who have made updates after create" do
      card_subject.update! content: "changed"

      expect(format_subject.render_updated_by).to be_match(/Joe User/)
    end
  end
end
