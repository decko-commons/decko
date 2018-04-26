describe Card::Format::Render do
  describe "render" do
    it "return nil with 'optional: :hide' argument" do
      rendered = Card["A"].format(:html).render(:open, optional: :hide)
      expect(rendered).to be_blank
    end
  end

  describe "view cache" do
    before { Cardio.config.view_cache = true }
    after { Cardio.config.view_cache = false }

    let(:cache_key) do
      "z-Card::Format::HtmlFormat-normal-home_view:content;"\
      "nest_name:Z;nest_syntax:Z|content;view:contentcontent:show"
    end

    subject { Card::Cache[Card::View] }

    it "can be changed with nest option" do
      is_expected.to receive(:fetch).with cache_key
      render_content "{{Z|content}}"
      is_expected.not_to receive(:fetch)
      render_content "{{Z|cache:never}}"
    end

  end
end
