# -*- encoding : utf-8 -*-

RSpec.describe Card::View::Permission do
  it "catches recursive nesting in #ok_view" do
    card = Card["A"]
    card.update_attributes! content: "{{_|core}}"
    expect { card.format.render :core }
      .to raise_error(/you're too deep/)
  end
end
