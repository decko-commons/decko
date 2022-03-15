# -*- encoding : utf-8 -*-

RSpec.describe Card::Codename, "Codename" do
  before do
    @codename = :default
  end

  it "is sane" do
    expect(Card[@codename].codename).to eq(@codename)
    card_id = described_class.id @codename
    expect(card_id).to be_a_kind_of Integer
    expect(described_class[card_id]).to eq(@codename)
  end

  it "makes cards indestructible" do
    Card::Auth.as_bot do
      card = Card[@codename]
      card.delete
      expect(card.errors[:delete].first).to match "is a system card"
      expect(Card[@codename]).to be
    end
  end

  describe "#id!" do
    it "raises error for missing codename" do
      expect { described_class.id! :not_a_codename }
        .to raise_error(Card::Error::CodenameNotFound, /unknown codename: not_a_codename/)
    end
  end

  describe "#id" do
    example "symbol" do
      expect(described_class.id(:all)).to eq Card.id(:all)
    end

    example "id" do
      all_id = Card.id(:all)
      expect(described_class.id(all_id)).to eq all_id
    end

    example "string" do
      expect(described_class.id("all")).to eq Card.id(:all)
    end

    example "missing codename" do
      expect(described_class.id("unknown")).to eq nil
    end
  end

  describe "#[]" do
    example "symbol" do
      expect(described_class[:all]).to eq :all
    end

    example "id" do
      all_id = Card.id(:all)
      expect(described_class[all_id]).to eq :all
    end

    example "string" do
      expect(described_class["all"]).to eq :all
    end

    example "missing codename" do
      expect(described_class["unknown"]).to eq nil
    end
  end
end
