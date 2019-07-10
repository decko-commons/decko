# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::List do
  it "handles references", aggregate_failures: true do
    content = "A\n[[+B]]\n[[C]]"
    card = create_list "test", content
    refs = Card::Reference.where(referer_id: card.id).pluck(:referee_key, :ref_type)
    expect(card.content).to eq content
    expect(refs).to contain_exactly %w[a L], %w[b P], %w[c L], %w[test+b L]
  end

  specify "#item_names" do
    card = Card.new name:"test", type_id: Card::ListID,
                       content: "A\n[[+B]]\n[[C]]"
    expect(card.item_names).to eq %w[A test+B C]
  end
end
