# -*- encoding : utf-8 -*-

RSpec.describe Card::Codename, "Codename" do
  before do
    @codename = :default
  end

  it "is sane" do
    expect(Card[@codename].codename).to eq(@codename)
    card_id = Card::Codename[@codename]
    expect(card_id).to be_a_kind_of Integer
    expect(Card::Codename[card_id]).to eq(@codename)
  end

  it "makes cards indestructable" do
    Card::Auth.as_bot do
      card = Card[@codename]
      card.delete
      expect(card.errors[:delete].first).to match "is a system card"
      expect(Card[@codename]).to be
    end
  end

  it "raises error for missing codename" do
    expect { Card::NotACodenameID }
      .to raise_error "Missing codename not_a_codename (NotACodenameID)"
  end
end
