# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::BootswatchSkin do
  CUSTOM_CSS = "body{background-color:#123}".freeze
  YETI_THEME_CSS = "background-color:#f6f6f6;".freeze

  let(:customized_skin) do
    Card::Env.params[:theme] = "yeti"
    create "customized yeti skin", type: :customized_bootswatch_skin
  end

  let(:style_with_customized_theme) do
    create "style with customized theme+*style",
           type: :pointer, content: customized_skin.name
  end

  def generated_css
    File.read(style_with_customized_theme.machine_output_path)
  end

  it "adds bootswatch styles to machine output" do
    style_with_customized_theme.update_machine_output
    expect(generated_css).to include YETI_THEME_CSS
  end

  context "when item added to stylesheets pointer" do
    it "updates output of related machine card", as_bot: true do
      create "new_style", type: :css, content: CUSTOM_CSS
      customized_skin.field(:stylesheets).add_item! "new_style"
      expect(generated_css).to include CUSTOM_CSS
    end
  end

  context "when stylesheets item content changed" do
    it "updates output of related machine card", as_bot: true do
      customized_skin.field(:bootswatch).update_attributes! content: CUSTOM_CSS
      expect(generated_css).to include CUSTOM_CSS
    end
  end
end
