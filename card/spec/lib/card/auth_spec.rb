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

  context "with api key" do
    before do
      @joeadmin = Card["Joe Admin"]
      @api_key = "abcd"
      Card::Auth.as_bot do
        @joeadmin.account.api_key_card.update! content: @api_key
      end
    end

    it "sets current from api key" do
      Card::Auth.signin_with_api_key @api_key
      expect(Card::Auth.current_id).to eq(@joeadmin.id)
    end
  end
end
