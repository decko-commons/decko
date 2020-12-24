RSpec.describe Card::Set::Type::Cardtype do
  it "can only be deleted when no instances present" do
    city = create_cardtype "City"
    sparta = create_city "Sparta"
    expect(sparta.type_id).to eq city.id
    expect { city.delete! }
        .to raise_error(/this card must remain/)
    expect(Card["City"]).to be_a(Card)
    sparta.delete!
    expect { city.delete! }
        .not_to raise_error
  end

  it "type can't be change when instances present" do
    expect { update "Cardtype A", type_id: Card::BasicID }
        .to raise_error(/can't alter this type/)
    Card["type-a-card"].delete!
    expect { update "Cardtype A", type_id: Card::BasicID }
        .not_to raise_error
    expect(Card["Cardtype A"]).to have_type :basic
  end

  specify "no cards without cardtype" do
    Card.all.each do |card|
      expect(card.type_card).to be_a(Card)
    end
  end

  describe "new Cardtype" do
    let(:ct) do
      Card::Auth.as_bot do
        Card.create! name: "Animal", type: "Cardtype"
      end
    end

    it "has create permissions" do
      expect(ct.who_can(:create)).not_to be_nil
    end

    it "its create permissions should be based on Basic" do
      expect(ct.who_can(:create)).to eq(Card[:basic].who_can(:create))
    end
  end
end