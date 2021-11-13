# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::CoffeeScript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }

  def create_coffee_card name, content
    ensure_card name, type: Card::CoffeeScriptID, content: content
  end

  it_behaves_like "asset inputter", that_produces: :js do
    let(:create_asset_inputter_card) do
      create_coffee_card "coffee inputter", coffee
    end
    let(:create_another_asset_inputter_card) do
      create_coffee_card"more coffeee", changed_coffee
    end
    let(:create_outputter_card) do
      ensure_card "coffee machine", type: :pointer
    end
    let(:card_content) do
      { in: coffee,
        out: "//coffee machine\n#{compressed_coffee}",
        changed_in: changed_coffee,
        changed_out: "//coffee machine\n#{compressed_changed_coffee}" }
    end
  end
end
