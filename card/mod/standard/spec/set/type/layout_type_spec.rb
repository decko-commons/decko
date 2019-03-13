# -*- encoding : utf-8 -*-

describe Card::Set::Type::LayoutType do
  it "includes Html card methods" do
    expect(Card.new(type: "Layout").clean_html?).to be_falsey
  end

  it "doesn't render main nest" do
    expect_view(:core, card: "Default Layout").to have_tag :pre do
      without_tag "div#main"
    end
  end
end
