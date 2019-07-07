# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Roles do
  it "shark can't assign Administrator role", with_user: "Joe User" do
    card = Card.fetch "u1+*roles"
    card.update content: "Administrator"
    expect(card.errors[:permission_denied])
      .to include(/You don't have permission to assign the role Administrator/)
  end

  it "shark can't assign Administrator to himself", with_user: "Joe User" do
    card = Card.fetch "Joe User+*roles"
    card.update content: "Administrator"
    expect(card.errors[:permission_denied])
      .to include(/You don't have permission to assign the role Administrator/)
  end

  it "user can't change role", with_user: "Joe Camel" do
    card = Card.fetch "u1+*roles"
    card.update content: "Shark"
    expect(card.errors[:permission_denied])
      .to include("You don't have permission to update u1+*roles")
  end
end
