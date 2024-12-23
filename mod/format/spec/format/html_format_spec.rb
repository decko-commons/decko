# -*- encoding : utf-8 -*-

RSpec.describe Card::Format::HtmlFormat do
  describe "views" do
    specify "content" do
      expect(view(:content, card: "A+B"))
        .to have_tag(
          'div[class="card-slot content-view ALL ALL_PLUS TYPE-rich_text ' \
          'RIGHT-b TYPE_PLUS_RIGHT-rich_text-b SELF-a-b d0-card-content"]'
        )
    end

    specify "nests in multi edit" do
      expect(view(:edit, card: { type: "Book" })).to have_tag "fieldset" do
        with_tag "div.content-editor" do
          with_tag "textarea", name: "card[subcards][+illustrator][content]"
        end
      end
    end

    specify "titled" do
      expect(view(:titled, card: "A+B")).to have_tag 'div[class~="titled-view"]' do
        with_tag 'div[class~="d0-card-header"]' do
          with_tag 'span[class~="card-title"]'
        end
        with_tag 'div[class~="d0-card-body d0-card-content"]', "AlphaBeta"
      end
    end

    # it "joins arrays" do
    #   format =
    #     Card["A"].format_with do
    #       view(:array) { ["A", nil, %w[B C]] }
    #     end
    #   expect(format.render_array).to eq "A\nB\nC"
    # end
  end
end
