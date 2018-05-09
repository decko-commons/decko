# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::Pointer do
  describe "css" do
    before do
      @css = "#box { display: block }"
      Card.create name: "my css", content: @css
    end
    it "renders CSS of items" do
      css_list = render_card(
          :content,
          { type: Card::PointerID, name: "my style list", content: "[[my css]]" },
          format: :css
      )
      #      css_list.should =~ /STYLE GROUP\: \"my style list\"/
      #      css_list.should =~ /Style Card\: \"my css\"/
      css_list.should =~ /#{Regexp.escape @css}/
    end
  end
end