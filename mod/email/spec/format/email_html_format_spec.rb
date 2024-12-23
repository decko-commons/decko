# -*- encoding : utf-8 -*-

RSpec.describe Card::Format::EmailHtmlFormat do
  it "renders full urls" do
    Cardio.with_config deck_origin: "http://www.fake.com" do
      expect(render_content("[[B]]", format: "email_html"))
        .to eq('<a class="known-card" href="http://www.fake.com/B">' \
               '<span class="card-title" title="B">B</span></a>')
    end
  end

  describe "raw view" do
    it "renders missing included cards as blank" do
      expect(render_content("{{strombooby}}", format: "email_html")).to eq("")
    end
  end
end
