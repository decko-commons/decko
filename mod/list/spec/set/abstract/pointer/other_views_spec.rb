# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Pointer do
  before do
    Card::Env.params[:max_export_depth] = 4
  end

  describe "json" do
    include_context "json context"

    def card_subject
      sample_pointer
    end

    let(:item_names) { %w[u1 u2 u3] }

    specify "view: links" do
      expect_view(:links, format: :json).to eq([])
    end

    specify "view: items" do
      expect_view(:items, format: :json)
        .to contain_exactly(*item_names.map { |i| atom_values Card[i] })
    end
  end

  describe "css" do
    let(:css) { "#box { display: block }" }

    before do
      Card.create name: "my css", content: css
    end

    it "renders CSS of items" do
      css_list = render_card(
        :content,
        { type: Card::PointerID, name: "my style list", content: "my css" },
        { format: :css }
      )
      #      css_list.should =~ /STYLE GROUP\: \"my style list\"/
      #      css_list.should =~ /Style Card\: \"my css\"/
      expect(css_list).to match(/#{Regexp.escape css}/)
    end
  end
end
