# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::CoffeeScript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }

  it_behaves_like "content machine", that_produces: :js do
    let(:machine_card) do
      Card.gimme! "coffee machine", type: Card::CoffeeScriptID,
                                    content: coffee
    end
    let(:card_content) do
      { in: coffee,
        out: "//coffee machine\n#{compressed_coffee}",
        changed_in: changed_coffee,
        changed_out: "//coffee machine\n#{compressed_changed_coffee}" }
    end
  end
end
