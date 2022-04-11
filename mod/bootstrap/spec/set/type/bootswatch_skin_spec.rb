# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::BootswatchSkin do
  CUSTOM_CSS = "body{background-color:#123}".freeze
  YETI_THEME_CSS = "background-color:#f6f6f6;".freeze

  let :customized_skin do
    create "customized yeti skin", type: :bootswatch_skin,
                                   subfields: { parent: :yeti_skin.cardname }
  end

  let(:style_with_customized_theme) do
    create "A+*self+*style", type: :pointer, content: customized_skin.name
  end

  def generated_css
    File.read(style_with_customized_theme.asset_output_path)
  end

  it "adds bootswatch styles to asset output" do
    style_with_customized_theme.update_asset_output
    expect(generated_css).to include YETI_THEME_CSS
  end

  specify ".read_bootstrap_variables" do
    expect(customized_skin.read_bootstrap_variables).to include "$primary"
  end

  example "update old skin", as_bot: true do
    create_skin "old skin", content: ["bootstrap default skin", "custom css"]
    Card["old skin"].update! type: :bootswatch_skin

    expect_card("old skin")
      .to have_a_field(:stylesheets).pointing_to "custom css"
  end

  describe "+:colors" do
    it "includes color definitions", as_bot: true do
      customized_skin.colors_card.update! content: "$primary: $cyan !default"
      expect(customized_skin.content).to include "$primary: $cyan !default"
    end
  end

  describe "+:stylesheets list" do
    def create_and_add_style content
      create "new_style", type: :css, content: content
      customized_skin.stylesheets_card.add_item! "new_style"
    end

    it "updates asset output on create", as_bot: true do
      create_and_add_style CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end

    it "updates asset output on update", as_bot: true do
      create_and_add_style ""
      "new style".card.update! content: CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end
  end
end
