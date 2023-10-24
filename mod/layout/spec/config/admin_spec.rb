RSpec.describe "layout mod" do
  specify "admin config" do
    card = Card.fetch(:mod_layout)
    aggregate_failures do
      expect(card.settings).to eq %i[layout head]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq %i[layout_type]
    end
  end

  specify "admin view" do
    expect(render_card(:admin, :mod_layout)).to have_tag :h2, text: "Settings"
  end
end
