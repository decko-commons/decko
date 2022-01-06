RSpec.describe Card::Env::Location do
  describe "#cardname_from url" do
    before { Card.config.deck_origin = "http://woot.io" }
    after { Card.config.deck_origin = nil }

    def url2name url
      described_class.cardname_from_url url
    end

    # it "extracts names from urls" do
    #   expect(url2name("woot.io/home")).to eq("home")
    # end

    it "handles protocols" do
      expect(url2name("http://woot.io/home")).to eq("home")
    end

    it "returns nil if host is missing" do
      expect(url2name("http://wootnot.io/home")).to be_nil
    end

    it "handles codenames" do
      expect(url2name("http://woot.io/:search_type")).to eq("Search")
    end
  end
end
