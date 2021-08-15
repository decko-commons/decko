RSpec.describe Card::Set::Type::Markdown do
  def markdown_core text
    card_subject.content = text
    format_subject._render_core.tr "\n", ""
  end

  describe "core view" do
    it "renders markdown" do
      expect(markdown_core("### Header\n`puts Hello World!`"))
        .to eq %(<h3 id="header">Header</h3><p><code>puts Hello World!</code></p>)
    end

    it "handles nests" do
      expect(markdown_core("{{B|link}}"))
        .to eq('<p><a class="known-card" href="/B">' \
               '<span class="card-title" title="B">B</span></a></p>')
    end

    it "handles escaped nests" do
      expect(markdown_core("\\{{B|link}}"))
        .to eq("<p>{{B|link}}</p>")
    end
  end
end
