RSpec.describe Card::Set::All::Codename do
  describe "codename" do
    let(:card) { Card["c"] }

    it "requires admin permission" do
      card.update codename: "structure"
      expect(card.errors[:codename].first).to match(/only admins/)
    end

    it "checks uniqueness" do
      Card::Auth.as_bot do
        card.update codename: "structure"
        expect(card.errors[:codename].first).to match(/already in use/)
      end
    end
  end

  describe "reset_codename_cache" do
    it "resets codename cache when codename is updated" do
      card = Card.create! name: "Codename Haver", codename: :codename_haver
      expect(Card::Codename.id(:codename_haver)).to eq(card.id)
    end
  end
end
