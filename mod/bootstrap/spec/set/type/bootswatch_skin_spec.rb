# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::BootswatchSkin do
  CUSTOM_CSS = "body{background-color:#123}".freeze
  YETI_THEME_CSS = "background-color:#f6f6f6;".freeze

  let :customized_skin do
    Card::Env.params[:theme] = "yeti"
    create "customized yeti skin",
           type: :customized_bootswatch_skin,
           subfields: { parent: :yeti_skin.cardname }
  end

  let(:style_with_customized_theme) do
    create "A+*self+*style",
           type: :pointer, content: customized_skin.name
  end

  def generated_css
    File.read(style_with_customized_theme.asset_output_path)
  end

  it "adds bootswatch styles to asset output" do
    style_with_customized_theme.update_asset_output
    expect(generated_css).to include YETI_THEME_CSS
  end

  context "when item added to stylesheets pointer" do
    it "updates output of related asset output card", as_bot: true do
      create "new_style", type: :css, content: CUSTOM_CSS
      customized_skin.fetch(:stylesheets).add_item! "new_style"
      expect(generated_css).to include CUSTOM_CSS
    end
  end

  context "when stylesheets item content changed" do
    it "updates output of related asset output card", as_bot: true do
      customized_skin.fetch(:bootswatch).update! content: CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end
  end
end
