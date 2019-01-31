# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::ProcessLayout do
  let(:layout_card) { Card["tmp layout"] }

  describe "simple page with Default Layout" do
    subject(:open_view) { Card["A+B"].format.show(:open, {}) }

    it "renders top menu" do
      expect(open_view).to have_tag "header" do
        with_tag 'a.nav-link.internal-link[href="/"]', text: "Home"
        with_tag 'a.nav-link.internal-link[href="/:recent"]', text: "Recent"
        with_tag 'form.navbox-form[action="/*search"]' do
          with_tag 'select[name="query[keyword]"]'
        end
      end
    end

    it "renders card header" do
      expect(open_view).to have_tag "div.d0-card-header.card-header" do
        with_tag "div.d0-card-header-title" do
          with_tag "span.card-title", text: "A+B"
        end
      end
    end

    it "renders card content" do
      expect(open_view).to have_tag "div.d0-card-body.d0-card-content" \
                                    ".ALL.ALL_PLUS" \
                                    ".TYPE-basic.RIGHT-b.TYPE_PLUS_RIGHT-basic-b" \
                                    ".SELF-a-b.card-body.card-text",
                                    text:  /AlphaBeta/
    end

    it "renders card credit" do
      expect(open_view).to have_tag 'div[class~="SELF-Xcredit"]' do
        with_tag "img"
        with_tag "a", text: "Decko v#{Card::Version.release}"
      end
    end
  end

  describe "layout defined by rule" do
    it "renders layout from card" do
      with_layout "<pre>Hey {{_main}}</pre>"
      expect(format_subject.show(:core, {})).to have_tag :pre do
        with_text(/Hey/)
        with_tag "div#main", /Alpha/
      end
    end

    it "respects custom view in params" do
      with_layout "<pre>Hey {{_main}}</pre>"
      expect(format_subject.show(:type, {})).to have_tag :pre do
        with_text(/Hey/)
        with_tag "div#main", "Basic"
      end
    end

    it "respect custom view in main nest" do
      with_layout "<pre>Hey {{_main|type}}</pre>"
                         .and_return [:other, [:modal, { opts: :a} ]]
      expect(format_subject.show(nil, {})).to have_tag :pre do
        with_text(/Hey/)
        with_tag "div#main", "Basic"
      end
    end
  end

  example "layout as render option" do
    expect(format_subject.render(:core, layout: :pre))
      .to have_tag :pre, /Alpha/
  end

  example "layout as nest option" do
    expect(format_subject.nest("A", layout: :pre))
      .to have_tag :pre, /Alpha/
  end

  example "layout as param", params: { layout: :pre } do
    expect(format_subject.show(:core, layout: {}))
      .to have_tag :pre, /Alpha/
  end

  def with_layout content
    Card::Layout.clear_cache
    create_layout "tmp layout", content: "<body>#{content}</body>"
    Card["*all+*layout"].content = "[[tmp layout]]"
    Card["tmp layout"].refresh
  end

  it "does not recurse" do
    with_layout "Mainly {{_main|core}}"

    expect(layout_card.format.show(nil, {})).to have_tag "div#main" do
      with_tag "div.code" do
        with_tag "pre", "Mainly {{_main|core}}"
      end
    end
  end

  it "handles nested _main references" do
    with_layout "{{outer space|core}}"
    create "outer space", content: "{{_main|name}}"

    expect(format_subject.show(nil, {}))
      .to have_tag "div#main", "A"
  end
end
