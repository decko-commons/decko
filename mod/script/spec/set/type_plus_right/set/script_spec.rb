# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Set::Script do
  it "validates item type" do
    card = Card.create name: "A+*self+*script", content: "B"
    expect(card.errors[:content].first)
      .to include("B has an invalid type: RichText. " \
                  "Allowed types: JavaScript, CoffeeScript, and List.")

    Card.ensure name: "test script", type: :java_script
    card = Card.create name: "A+*self+*script", content: "test script"
    expect(card.errors[:type]).to be_empty
  end
end
