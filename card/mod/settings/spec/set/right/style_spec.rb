# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Style do
  #  describe "#delet"
  #  it "deletes tempfile"
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  let(:new_css)                { "#box{ display: none}\n"   }
  let(:compressed_new_css)     { "#box{display:none}\n"   }

  it_behaves_like "pointer machine", that_produces: :css do
    let(:machine_card) do
      Card.gimme! "test my style+*style", type: :pointer, content: ""
    end
    let(:machine_input_card) do
      Card.gimme! "test css", type: :css, content: css
    end
    let(:another_machine_input_card) do
      Card.gimme! "more css", type: :css, content: new_css
    end
    let(:expected_input_items) { nil }
    let(:input_type) { :css }
    let(:card_content) do
      { in:           css,         out:     compressed_css,
        changed_in:   changed_css, changed_out: compressed_changed_css,
        new_in:       new_css,     new_out:     compressed_new_css }
    end
  end
end
