RSpec.describe Card::Set::All::ContextualContent do
  describe "#contextual_content" do
    let(:context_card) { Card["A"] }

    # refers to 'Z'
    it "processes nests relative to context card" do
      c = create "foo", content: "{{_self+B|core}}"
      expect(c.format.contextual_content(context_card)).to eq("AlphaBeta")
    end

    # why the heck is this good?  -efm
    it "returns content even when context card is structured" do
      create "A+*self+*structure", content: "Banana"
      c = create "foo", content: "{{_self+B|core}}"
      expect(c.format.contextual_content(context_card)).to eq("AlphaBeta")
    end

    it "doesn't use chunk list of context card" do
      c = create "foo", content: "test@email.com", type: "HTML"
      expect(c.format.contextual_content(context_card)).not_to have_tag "a"
    end
  end
end
