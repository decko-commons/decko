RSpec.describe Card::Set::All::GoogleAnalytics do
  before { Cardio.config.google_analytics_key = "UA-34941429-6" }

  after { Cardio.config.google_analytics_key = nil }

  it "instantiates a tracker" do
    expect(card_subject.tracker).to be_a(Staccato::Tracker)
  end

  describe "google_analytics_snippet" do
    it "handles vars" do
      expect(format_subject.render_google_analytics_snippet)
        .to match(/#{Regexp.escape "ga('set', 'anonymizeIp', true)"}/)
    end
  end
end
