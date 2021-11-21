
# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::CoffeeScript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }

  def create_coffee_card name, content
    ensure_card name, type: Card::CoffeeScriptID, content: content
  end

  # script outputters can't be changed with cards
  # it_behaves_like "asset inputter", that_produces: :js do
  #   let(:inputter_name) do
  #     "coffee inputter"
  #   end
  #   let(:create_asset_inputter_card) do
  #     create_coffee_card inputter_name, coffee
  #   end
  #   let(:create_another_asset_inputter_card) do
  #     create_coffee_card "more coffee", changed_coffee
  #   end
  #   let(:create_asset_outputter_card) do
  #     mod_card = ensure_card "mod: coffee test", type: :mod
  #     ensure_card [mod_card.name, :script], type: :list
  #   end
  #   let(:card_content) do
  #     { in: coffee,
  #       out: "// #{inputter_name}\n#{compressed_coffee}",
  #       added_out: "// #{inputter_name}\n#{compressed_coffee}\n// more coffee\n#{compressed_changed_coffee}",
  #       changed_in: changed_coffee,
  #       changed_out: "// #{inputter_name}\n#{compressed_changed_coffee}" }
  #   end
  # end
end
