describe Card::Format::Render do
  describe "render" do
    it "return nil with 'optional: :hide' argument" do
      rendered = Card["A"].format(:html).render(:open, optional: :hide)
      expect(rendered).to be_blank
    end
  end

  describe "view cache" do
    subject { Card::Cache[Card::View] }

    before { Cardio.config.view_cache = true }

    after { Cardio.config.view_cache = false }

    let(:cache_key) do
      "#{'Z'.card_id}-Card::Format::HtmlFormat-normal-home_view:content;" \
      "nest_name:Z;nest_syntax:Z|content;view:contentcontent:show;edit_button:hide;menu:hide"
    end

    it "can be changed with nest option" do
      is_expected.to receive(:fetch).with cache_key
      render_content "{{Z|content}}"
      is_expected.not_to receive(:fetch)
      render_content "{{Z|cache:never}}"
    end
  end

  describe "voo.wrap" do
    let :wrapped_main_view do
      Card::Env.with_params layout: :default, view: :core do
        Card["Joe User+*account+*password"].format.render_with_layout :core, :default
        # + password cards wrap their core view in "em"
      end
    end

    it "wraps inside layout" do
      expect(wrapped_main_view).to have_tag("article") do
        with_tag "em", "encrypted"
      end
    end
  end
end
