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

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) do
      Card.gimme! "test scss", type: :scss, content: scss
    end
    let(:create_another_machine_input_card) do
      Card.gimme! "more scss", type: :scss, content: scss
    end
    let(:create_machine_card) do
      Card.gimme! "style with scss+*style", type: :pointer
    end
    let(:card_content) do
      { in:         scss,         out:     compressed_css,
        changed_in: changed_scss, changed_out: compressed_changed_css }
    end
  end

  it "processes links and nests but not urls", as_bot: true do
    scss = ".TYPE-X.no-citations {\n  color: #BA5B5B;\n}\n"
    card = Card.create! name: "minimal css", type: "scss", content: scss
    card.format(:css).render_core.should == scss
  end

  it_behaves_like "content machine", that_produces: :css do
    let(:machine_card) { Card.gimme! "test scss", type: :scss, content: scss }
    let(:card_content) do
      { in:         scss,         out:     compressed_css,
        changed_in: changed_scss, changed_out: compressed_changed_css }
    end
  end
end
