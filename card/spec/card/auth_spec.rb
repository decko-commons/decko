# -*- encoding : utf-8 -*-

RSpec.describe Card::Auth do
  before do
    described_class.signin Card::AnonymousID
  end

  let(:joeuserid) { "Joe User".card_id }

  it "authenticates user" do
    authenticated = described_class.authenticate "joe@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(joeuserid)
  end

  it "authenticates user despite whitespace" do
    authenticated = described_class.authenticate " joe@user.com ", " joe_pass "
    expect(authenticated.left_id).to eq(joeuserid)
  end

  it "authenticates user with weird email capitalization" do
    authenticated = described_class.authenticate "JOE@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(joeuserid)
  end

  it "sets current directly from id when mark is id" do
    described_class.signin joeuserid
    expect(described_class.current_id).to eq(joeuserid)
  end
end
