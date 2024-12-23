# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Session do
  it "stores content in session", :aggregate_failures, :as_bot do
    create_session "sesh", "some content"
    expect(Card.fetch("sesh", new: { type: :session }).content)
      .to eq "some content"
    expect(Card::Env.session["_card_sesh"]).to eq "some content"
    expect(Card.fetch("sesh")).to be_nil
  end

  it "is possible to access content before save" do
    card = Card.new name: "sesh", content: "content", type: :session
    expect(card.content).to eq "content"
  end

  example "update content" do
    create_session "sesh", "some content"
    card = Card.fetch("sesh", new: { type: :session })
    card.content = "new content"
    expect(card.content).to eq "new content"
  end

  example "delete content", :aggregate_failures, :as_bot do
    create_session "sesh", "some content"
    card = Card.fetch("sesh", new: { type: :session })

    expect(card.content).to eq "some content"
    expect(Card::Env.session["_card_sesh"]).to eq "some content"
    card.delete!
    expect(Card::Env.session["_card_sesh"]).to be_nil
  end
end
