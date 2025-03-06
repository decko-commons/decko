# -*- encoding : utf-8 -*-

CUSTOM_CSS = "body{background-color:#123}".freeze
YETI_THEME_CSS = "background-color:#f6f6f6;".freeze

RSpec.describe Card::Set::Type::BootswatchSkin do
  let(:customized_skin) { "customized yeti skin".card }
  let(:style_with_customized_theme) { "*colors+*self+*style".card }

  def generated_css
    File.read(style_with_customized_theme.asset_output_path)
  end

  # the bootswatch skin has the word error in it, so the following doesn't work
  # check_views_for_errors

  it "adds bootswatch styles to asset output" do
    style_with_customized_theme.update_asset_output
    expect(generated_css).to include YETI_THEME_CSS
  end

  specify ".read_bootstrap_variables" do
    expect(customized_skin.read_bootstrap_variables).to include "$primary"
  end

  example "update old skin", :as_bot do
    Card["old skin"].update! type: :bootswatch_skin

    expect_card("old skin")
      .to have_a_field(:stylesheets).pointing_to "old custom css"
  end

  describe "+:colors" do
    it "includes color definitions", :as_bot do
      customized_skin.colors_card.update! content: "$primary: #000 !default"
      expect(customized_skin.content).to include "$primary: #000 !default"
    end
  end

  describe "+:stylesheets list" do
    def create_and_add_style content
      create "new_style", type: :css, content: content
      customized_skin.stylesheets_card.add_item! "new_style"
    end

    it "updates asset output on create", :as_bot do
      create_and_add_style CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end

    it "updates asset output on update", :as_bot do
      create_and_add_style ""
      "new style".card.update! content: CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end
  end
end
