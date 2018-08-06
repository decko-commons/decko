# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Layout do
  context "simple page with Default Layout" do
    subject { view(:layout, card: "A+B") }

    it "renders top menu" do
      is_expected.to have_tag "header" do
        with_tag 'a.nav-link.internal-link[href="/"]', text: "Home"
        with_tag 'a.nav-link.internal-link[href=":recent"]', text: "Recent"
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

  example "layout as render option" do
    expect(format_subject.render(:core, layout: :bridge))
      .to have_tag :pre

  end

  example "layout as nest option" do
    expect(format_subject.nest("A", layout: :pre))
      .to have_tag :pre
  end

  example "layout as param" do
    expect(format_subject.nest("A", layout: :pre))
      .to have_tag :pre
  end



  let(:main_card) { Card.fetch("Joe User") }

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
  #
  # script:
  # style:
  #
  # layout: modal
  #
  # {{_main}}
  #
  # {{_main}}

  # with_main_card_and_opts card, opts do
  #   render layout_card, view: :closed
  # end

  context "when layout in params" do
  end

  def with_layout content
    create_layout "tmp layout", content: content
    Card["*all+*layout"].content = "[[tmp layout]]"
  end

  let(:layout_card) { Card["tmp layout"] }

  it "renders custom view of main" do
    with_layout "Hey {{_main|name}}"

    result = main_card.format.render_layout
    expect(result).to match(/Hey.*div.*Joe User/)
    expect(result).not_to match(/d0-card-header/)
  end

  it "does not recurse" do
    with_layout "Mainly {{_main|core}}"

    expect_view(:layout, card: layout_card).to have_tag "div#main" do
      with_tag "div.code" do
        with_tag "pre", "Mainly {{_main|core}}"
      end
    end
  end

  it "handles nested _main references" do
    with_layout "{{outer space|core}}"
    create "outer space", content: "{{_main|name}}"

    expect_view(:layout, card: main_card).to have_tag "div#main", "Joe User"
  end
end
