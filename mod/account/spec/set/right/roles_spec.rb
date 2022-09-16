# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Roles do
  it "shark can't assign Administrator role", with_user: "Joe User" do
    card = Card.fetch "Administrator+*members"
    card.update content: "u1"
    expect(card.errors[:permission_denied])
      .to include(/You don't have permission to update Administrator\+\*members/)
  end

  it "shark can't assign Administrator to himself", with_user: "Joe User" do
    card = Card.fetch "Administrator+*members"
    card.update content: "Joe User"
    expect(card.errors[:permission_denied])
      .to include(/You don't have permission to update Administrator\+\*members/)
  end

  it "user can't change role", with_user: "Joe Camel" do
    card = Card.fetch "Shark+*members"
    card.update content: "u1"
    expect(card.errors[:permission_denied])
      .to include("You don't have permission to update Shark+*members")
  end
end
