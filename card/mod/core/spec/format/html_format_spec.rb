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

    context "simple page with Default Layout" do
      subject { view(:layout, card: "A+B") }

      it "renders top menu" do
        is_expected.to have_tag "header" do
          with_tag 'a.nav-link.internal-link[href="/"]', text: "Home"
          with_tag 'a.nav-link.internal-link[href="/:recent"]', text: "Recent"
          with_tag 'form.navbox-form[action="/:search"]' do
            with_tag 'input[name="_keyword"]'
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
          @layout_card = Card.create name: "tmp layout", type: "Layout"
          # warn "layout #{@layout_card.inspect}"
        end
        c = Card["*all+*layout"]
        c.content = "[[tmp layout]]"
        @main_card = Card.fetch("Joe User")
        Card::Env[:main_name] = @main_card.name

        # warn "lay #{@layout_card.inspect}, #{@main_card.inspect}"
      end

      #      it "defaults to core view when in layout mode" do
      #        @layout_card.content = "Hi {{A}}"
      #        Card::Auth.as_bot { @layout_card.save }
      #
      #        expect(@main_card.format.render!(:layout)).to match('Hi Alpha')
      #      end

      #      it "defaults to open view for main card" do
      #        @layout_card.content='Open up {{_main}}'
      #        Card::Auth.as_bot { @layout_card.save }
      #
      #        result = @main_card.format.render_layout
      #        expect(result).to match(/Open up/)
      #        expect(result).to match(/card-header/)
      #        expect(result).to match(/Joe User/)
      #      end

      it "renders custom view of main" do
        @layout_card.content = "Hey {{_main|name}}"
        Card::Auth.as_bot { @layout_card.save }

        result = @main_card.format.render_layout
        expect(result).to match(/Hey.*div.*Joe User/)
        expect(result).not_to match(/d0-card-header/)
      end

      it "does not recurse" do
        @layout_card.content = "Mainly {{_main|core}}"
        Card::Auth.as_bot { @layout_card.save }
        rendered = @layout_card.format.render! :layout
        expect(rendered).to have_tag "div#main" do
          have_tag "div.code" do
            have_tag("pre") { with_text "Mainly {{_main|core}}" }
          end
        end
      end

      it "handles nested _main references" do
        Card::Auth.as_bot do
          @layout_card.content = "{{outer space|core}}"
          @layout_card.save!
          Card.create name: "outer space", content: "{{_main|name}}"
        end
        rendered = @main_card.format.render! :layout
        expect(rendered).to have_tag "div#main" do
          with_text "Joe User"
        end
      end
    end
  end
end
