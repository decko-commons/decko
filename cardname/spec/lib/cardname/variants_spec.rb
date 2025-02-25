# encoding: utf-8

require_relative "../../spec_helper"

RSpec.describe Cardname::Variants do
  describe "#url_key" do
    cardnames = [
      "GrassCommons.org",
      "Oh you @##",
      "Alice's Restaurant!",
      "PB &amp; J",
      "Mañana"
    ].map(&:to_name)

    cardnames.each do |cardname|
      it "has the same key as the name" do
        expect(cardname.key).to eq(cardname.url_key.to_name.key)
      end
    end

    it "handles compound names cleanly" do
      expect("What?+the!+heck$".to_name.url_key).to eq("What+the+heck")
    end
  end

  describe "#safe_key" do
    it "subs pluses & stars" do
      expect("Alpha?+*be-ta".to_name.safe_key).to eq("alpha-Xbe_tum")
    end
  end
end
