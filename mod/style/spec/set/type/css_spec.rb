# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Css do
  let(:css)                    { "#box { display: block }" }
  let(:compressed_css)         { "#box{display:block}\n" }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n" }

  # it "highlights code" do
  #   Card::Auth.as_bot do
  #     css_card = Card.create! name: "tmp css", type_code: "css",
  #                             content: "p { border: 1px solid black; }"
  #     assert_view_select css_card.format.render_core, "div[class=CodeRay]"
  #   end
  # end

  def dummy_css name="test css"
    ensure_card name, type: :css, content: css
  end

  it_behaves_like "asset inputter", that_produces: :css  do
    let(:create_asset_inputter_card) { dummy_css }
    let(:create_another_asset_inputter_card) { dummy_css "more test css" }
    let(:create_asset_outputter_card) do
      ensure_card "A+*self+*style", type: :list
    end
    let(:card_content) do
      { in:         css,         out:         compressed_css,
        changed_in: changed_css, changed_out: compressed_changed_css }
    end
  end

  specify "core view in scss format" do
    rendered = render_card :core, { content: "{}", type: :css }, { format: :scss }
    expect(rendered).to eq "{}"
  end
end
