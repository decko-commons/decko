# -*- encoding : utf-8 -*-

describe Card::Set::Self::Version do
  it "has an X.X version" do
    expect(render_card(:raw, name: "*version")).to match(/^\d\.\d+/)
  end
end
