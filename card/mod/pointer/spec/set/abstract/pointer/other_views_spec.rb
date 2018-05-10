# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::Pointer do
  describe "css" do
    let(:css) { "#box { display: block }" }

    before do
      Card.create name: "my css", content: css
    end

    it "renders CSS of items" do
      css_list = render_card(
        :content,
        { type: Card::PointerID, name: "my style list", content: "[[my css]]" },
        format: :css
      )
      #      css_list.should =~ /STYLE GROUP\: \"my style list\"/
      #      css_list.should =~ /Style Card\: \"my css\"/
      expect(css_list).to match(/#{Regexp.escape css}/)
    end
  end
end
