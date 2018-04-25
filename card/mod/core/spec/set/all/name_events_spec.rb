describe Card::Set::All::NameEvents, "name event" do
  it "does not allow empty name" do
    expect { create "" }
      .to raise_error /Name can't be blank/
  end

  it "does not allow mismatched name and key" do
    expect { create "Test", key: "foo" }
      .to raise_error /wrong key/
  end

  it "resets codename cache when codename is updated" do
    card = Card.create! name: "Codename Haver", codename: :codename_haver
    expect(Card::Codename.id(:codename_haver)).to eq(card.id)
  end
end
