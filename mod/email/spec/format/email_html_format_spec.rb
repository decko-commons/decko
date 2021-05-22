# -*- encoding : utf-8 -*-

RSpec.describe Card::Format::EmailHtmlFormat do
  it "renders full urls" do
    Card::Env[:protocol] = "http://"
    Card::Env[:host] = "www.fake.com"
    expect(render_content("[[B]]", format: "email_html"))
      .to eq('<a class="known-card" href="http://www.fake.com/B">'\
                     '<span class="card-title" title="B">B</span></a>')
  end

  describe "raw view" do
    it "renders missing included cards as blank" do
      expect(render_content("{{strombooby}}", format: "email_html")).to eq("")
    end
  end
end
