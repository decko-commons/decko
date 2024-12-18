RSpec.describe Card::Set::Abstract::Delist do
  def card_subject_name
    "vertical"
  end

  let(:list_with_subject) { "stacks".card }

  it "deletes company from dataset when company is deleted", as_bot: true do
    expect(list_with_subject.item_names).to include(card_subject_name)
    card_subject.delete!
    expect(list_with_subject.item_names).not_to include(card_subject_name)
  end
end
