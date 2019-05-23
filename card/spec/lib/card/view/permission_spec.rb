# -*- encoding : utf-8 -*-

RSpec.describe Card::View::Permission do
  it "should catch recursive nesting in #ok_view" do
    card = Card["A"]
    card.update_attributes! content: "{{_|bar}}"
    expect { card.format.render :bar }
      .to raise_error(/you\'re too deep/)
  end
end