# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Scss do
  let(:scss) do
    <<-SCSS
      $link_color: #abcdef;
      a { color: $link_color; }
    SCSS
  end
  let(:compressed_css) { "a{color:#abcdef}\n" }
  let(:changed_scss) do
    <<-SCSS
      $link_color: #fedcba;
      a { color: $link_color; }
    SCSS
  end
  let(:compressed_changed_css) { "a{color:#fedcba}\n" }
  let(:scss_card) { Card[:style_right_sidebar] }

  it "highlights code in html" do
    assert_view_select scss_card.format(:html).render_core, "div[class=CodeRay]"
  end

  it "does not highlight code in css" do
    expect(scss_card.format(:css).render_core).not_to match(/CodeRay/)
  end

  it_behaves_like "asset inputter"  do
    let(:create_asset_inputter_card) { scss_card }
    let(:create_another_asset_inputter_card) { scss_card "more css" }
    let(:create_asset_outputter_card) do
      ensure_card "A+*self+*style", type: :list
    end
    let(:card_content) do
      { in:         scss,         out:         scss,
        changed_in: changed_scss, changed_out: changed_scss }
    end
  end

  it "processes links and nests but not urls", as_bot: true do
    scss = ".TYPE-X.no-citations {\n  color: #BA5B5B;\n}\n"
    card = Card.create! name: "minimal css", type: "scss", content: scss
    card.format(:css).render_core.should == scss
  end

  def scss_card name="test scss"
    ensure_card name, type: :scss, content: scss
  end

  describe "scss format" do
    it "doesn't compile scss in core view" do
      content = "$white: #fff;\np { background: $white; }"
      rendered = render_card :core, { content: content, type: :css }, { format: :scss }
      expect(rendered).to eq content
    end
  end

  it "validates syntax" do
    scss_card = Card.create name: "tmp scss", type_code: "scss", content: "body {\ninvalid\n}"
    expect(scss_card.errors[:content].first)
      .to include("Error: property \"invalid\" must be followed by a ':'")
    expect(scss_card.errors[:content].first)
      .to include("line 2")
  end

  it "validation fails for unknown variables" do
    scss_card = Card.create name: "tmp scss", type_code: "scss", content: "body {\ncolor: $invalid\n}"
    expect(scss_card.errors[:content].first)
      .to include("Error: Undefined variable: \"$invalid\"")
  end

  it "validation passes for known bootstrap variables" do
    scss_card = Card.create name: "tmp scss", type_code: "scss", content: "body {\ncolor: $primary\n}"
    expect(scss_card.errors[:content])
      .to be_empty
  end
end
