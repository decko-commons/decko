RSpec.describe Card::Set::Type::Markdown do
  describe "core view" do
    it "renders markdown" do
      card = Card.create! name: "Snark Town",
                          type: :markdown,
                          content: "### Header\n`puts Hello World!`"

      expect(card.format.render_core.tr("\n", ""))
        .to eq %(<h3 id="header">Header</h3><p><code>puts Hello World!</code></p>)
    end
  end
end
