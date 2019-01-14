# -*- encoding : utf-8 -*-

RSpec.describe Card::Format::HtmlFormat do
  describe "views" do
    specify "content" do
      expect(view(:content, card: "A+B"))
        .to have_tag(
          'div[class="card-slot content-view ALL ALL_PLUS TYPE-basic '\
          'RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b d0-card-content"]'
        )
    end

    specify "nests in multi edit" do
      expect(view(:edit, card: { type: "Book" })).to have_tag "fieldset" do
        have_tag 'div[class~="prosemirror-editor"]' do
          have_tag "input[name=?]", name: "card[subcards][+illustrator][content]"
        end
      end
    end

    specify "titled" do
      expect(view(:titled, card: "A+B")).to have_tag 'div[class~="titled-view"]' do
        have_tag 'div[class~="d0-card-header"]' do
          have_tag 'span[class~="card-title"]'
        end
        have_tag 'div[class~="d0-card-body d0-card-content"]', "AlphaBeta"
      end
    end

    it "joins arrays" do
      subject { view(:layout, card: "A+B") }

      it "renders top menu" do
        is_expected.to have_tag "header" do
          with_tag 'a.nav-link.internal-link[href="/"]', text: "Home"
          with_tag 'a.nav-link.internal-link[href="/:recent"]', text: "Recent"
          with_tag 'form.navbox-form[action="/*search"]' do
            with_tag 'select[name="query[keyword]"]'
          end
        end
      end

      it "renders card header" do
        is_expected.to have_tag "div.d0-card-header.card-header" do
          with_tag "div.d0-card-header-title" do
            with_tag "span.card-title", text: "A+B"
          end
        end
      end

      it "renders card content" do
        is_expected.to have_tag "div.d0-card-body.d0-card-content" \
                                ".ALL.ALL_PLUS" \
                                ".TYPE-basic.RIGHT-b.TYPE_PLUS_RIGHT-basic-b" \
                                ".SELF-a-b.card-body.card-text",
                                text:  /AlphaBeta/
      end

      it "renders card credit" do
        is_expected.to have_tag 'div[class~="SELF-Xcredit"]' do
          with_tag "img"
          with_tag "a", text: "Decko v#{Card::Version.release}"
        end
      end
    end

    context "layout" do
      before do
        Card::Auth.as_bot do
      format =
        Card["A"].format_with do
          view(:array) { ["A", nil, ["B", "C"]] }
        end
      expect(format.render_array).to eq "A\nB\nC"
    end
  end
end
