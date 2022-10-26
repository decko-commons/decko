RSpec.describe Card::Set::All::ItemAssignment do
  def card_subject
    "stacks".card
  end

  specify "#add_item!" do
    card_subject.add_item! "A"
    expect(card_subject.item_names).to eq %w[horizontal vertical A]
  end

  specify "#drop_item!" do
    card_subject.drop_item! "vertical"
    expect(card_subject.item_names).to eq %w[horizontal]
  end

  specify "#replace_item" do
    card_subject.replace_item "vertical", "A"
    expect(card_subject.item_names).to eq %w[horizontal A]
  end
end
