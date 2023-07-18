RSpec.describe Card::Set::All::Title do
  context "in text format" do
    it "renders title" do
      expect(format_subject(:base).render_title).to eq "A"
    end

    it "renders title with title arg" do
      expect(format_subject(:base).render!("title", title: "My Title"))
        .to eq "My Title"
    end
  end
end
