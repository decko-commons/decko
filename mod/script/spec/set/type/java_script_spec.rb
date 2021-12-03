# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::JavaScript do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }
  let(:js_card)               { create_js_card "js test card", js }

  def create_js_card name, content
    ensure_card name, type: Card::JavaScriptID, content: content
  end

  def comment_with_source content, source="js test card"
    "// #{source}\n#{content}"
  end

  specify "js core view" do
    expect_view(:core, format: :js, card: js_card).to eq js
  end

  xspecify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, format: :html, card: js_card)
      .to have_tag :script, with: { src: "/js_test_card.js" }
  end

  # script outputters can't be changed with cards
  # it_behaves_like "asset inputter", that_produces: :js  do
  #   let(:create_asset_inputter_card) { js_card }
  #   let(:create_another_asset_inputter_card) do
  #     create_js_card "more js", compressed_changed_js}
  #   end
  #   let(:create_asset_outputter_card) do
  #     mod_card = ensure_card "mod: script test", type: :mod
  #     ensure_card [mod_card.name, :script], type: :list
  #   end
  #   let(:card_content) do
  #     { in:          js,
  #       out:         comment_with_source(compressed_js),
  #       added_out:   "#{comment_with_source(compressed_js)}\n// " \
  #                    "more js\n#{compressed_changed_js}",
  #       changed_in:  changed_js,
  #       changed_out: comment_with_source(compressed_changed_js) }
  #   end
  # end
end
