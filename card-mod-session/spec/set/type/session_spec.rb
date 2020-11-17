# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Session do
  it "stores content in session", as_bot: true, aggregate_failures: true do
    create_session "sesh", "some content"
    expect(Card.fetch("sesh", new: { type_id: Card::SessionID }).content)
      .to eq "some content"
    expect(Card::Env.session["_card_sesh"]).to eq "some content"
    expect(Card.fetch("sesh")).to be_nil
  end

  it "is possible to access content before save" do
    card = Card.new name: "sesh", content: "content", type_id: Card::SessionID
    expect(card.content).to eq "content"
  end

  example "update content" do
    create_session "sesh", "some content"
    card = Card.fetch("sesh", new: { type_id: Card::SessionID })
    card.content = "new content"
    expect(card.content).to eq "new content"
  end

  example "delete content", as_bot: true, aggregate_failures: true do
    create_session "sesh", "some content"
    card = Card.fetch("sesh", new: { type_id: Card::SessionID })

    expect(card.content).to eq "some content"
    expect(Card::Env.session["_card_sesh"]).to eq "some content"
    card.delete!
    expect(Card::Env.session["_card_sesh"]).to be_nil
  end
end
