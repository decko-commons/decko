# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::LinkList do
  specify "#item_names" do
    card = Card.new name: "test", type_id: Card::LinkListID,
                    content: "[[A|text]]\n[[+B]]\n{{C|title: t}}"
    expect(card.item_names).to contain_exactly "A", "test+B", "C"
  end
end
