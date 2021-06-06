# -*- encoding : utf-8 -*-

describe Card::Set::Type::JavaScript do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }

  let(:js_card) { Card.new name: "js test card", type: :java_script, content: js}

  def comment_with_source content, source="test javascript"
    "//#{source}\n#{content}"
  end

  specify "js core view" do
    expect_view(:core, format: :js, card: js_card).to eq js
  end

  xspecify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, format: :html, card: js_card)
      .to have_tag :script, with: { src: "/js_test_card.js" }
  end

  it_behaves_like "content machine", that_produces: :js do
    let(:machine_card) do
      Card.gimme! "test javascript", type: :java_script, content: js
    end
    let(:card_content) do
      { in: js,
        out: comment_with_source(compressed_js),
        changed_in: changed_js,
        changed_out: comment_with_source(compressed_changed_js) }
    end
  end
end
