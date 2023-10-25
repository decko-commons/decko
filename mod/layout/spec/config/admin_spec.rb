RSpec.describe Card::Set::Type::Mod do
  specify "admin config of layout mod" do
    card = Card.fetch(:mod_layout)
    aggregate_failures do
      expect(card.settings).to eq %i[layout head]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq [["Styling", %i[layout_type]]]
    end
  end

  specify "admin view" do
    expect(render_card(:admin, :mod_layout)).to have_tag :h3, text: "Settings"
  end
end
