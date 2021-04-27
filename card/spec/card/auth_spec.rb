# -*- encoding : utf-8 -*-

RSpec.describe Card::Auth do
  before do
    Card::Auth.signin Card::AnonymousID
    @joeuserid = Card["Joe User"].id
  end

  it "authenticates user" do
    authenticated = Card::Auth.authenticate "joe@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "authenticates user despite whitespace" do
    authenticated = Card::Auth.authenticate " joe@user.com ", " joe_pass "
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "authenticates user with weird email capitalization" do
    authenticated = Card::Auth.authenticate "JOE@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "sets current directly from id when mark is id" do
    Card::Auth.signin @joeuserid
    expect(Card::Auth.current_id).to eq(@joeuserid)
  end
end
