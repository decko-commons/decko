# -*- encoding : utf-8 -*-

RSpec.describe Card::Codename, "Codename" do
  before do
    @codename = :default
  end

  it "is sane" do
    expect(Card[@codename].codename).to eq(@codename)
    card_id = Card::Codename.id @codename
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
      .to raise_error(Card::Error::CodenameNotFound, /unknown codename: not_a_codename/)
  end

  describe "#id" do
    example "symbol" do
      expect(Card::Codename.id(:all)).to eq Card.fetch_id(:all)
    end

    example "id" do
      all_id = Card.fetch_id(:all)
      expect(Card::Codename.id(all_id)).to eq all_id
    end

    example "string" do
      expect(Card::Codename.id("all")).to eq Card.fetch_id(:all)
    end

    example "missing codename" do
      expect(Card::Codename.id("unknown")).to eq nil
    end
  end

  describe "#[]" do
    example "symbol" do
      expect(Card::Codename[:all]).to eq :all
    end

    example "id" do
      all_id = Card.fetch_id(:all)
      expect(Card::Codename[all_id]).to eq :all
    end

    example "string" do
      expect(Card::Codename["all"]).to eq :all
    end

    example "missing codename" do
      expect(Card::Codename["unknown"]).to eq nil
    end
  end
end
