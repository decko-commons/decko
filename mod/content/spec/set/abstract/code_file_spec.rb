RSpec.describe Card::Set::Abstract::CodeFile do
  def card_subject
    :style_mods.card.recursed_item_cards.first
  end

  specify "#source_paths" do
    expect(card_subject.source_paths.first).to match(%r{mod/\w*/assets/style/\w*.scss})
  end

  specify "view bar_middle" do
    expect_view(:bar_middle).to have_tag("i.material-icons")
    expect_view(:bar_middle).to have_tag("span.text-muted")
  end
end
