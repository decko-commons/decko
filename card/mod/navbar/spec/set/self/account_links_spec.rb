# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::AccountLinks do
  it "has a 'my card' link" do
    account_links = render_card :core, name: "*account links"
    expect(account_links).to have_tag "div#logging" do
      have_tag 'a[class=~"my-card-link"]', text: "Joe User"
    end
  end
end
