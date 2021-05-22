# -*- encoding : utf-8 -*-

describe Card::Set::Right::WhenCreated do
  it "produces a text date" do
    expect(render_card(:core, name: "A+*when created")).to match(/\w+ \d+/)
  end
end
