require "sassc"

include_set Abstract::Css
include_set Abstract::AssetOutputter, output_format: :css, output_view: :compressed

def output_filetype
  "css"
end

def ok_to_read
  true
end

def make_asset_output_coded
  super ENV["STYLE_OUTPUT_MOD"]
end

format do
  # turn off autodetection of uri's
  def chunk_list
    :references
  end
end

format :html do
  HIDDEN_SKINS = %w[bootstrap_default_skin themeless_bootstrap_skin bootstrap_default_skin
                    classic_bootstrap_skin].freeze

  def default_item_view
    :bar
  end

  view :input, template: :haml

  def themes
    card.rule_card(:content_options).item_cards
  end

  def selectable_themes
    themes.reject do |theme_card|
      theme_card.right&.codename == :stylesheets ||
        theme_card.key.in?(HIDDEN_SKINS)
    end
  end
end

event :customize_theme, :prepare_to_validate, on: :update, when: :customize_theme? do
  skin_name = free_skin_name
  subcard skin_name, type_id: CustomizedBootswatchSkinID
  self.content = "[[#{skin_name}]]"
end

event :update_theme_input, :finalize,
      before: :update_asset_output_file, changed: :content do
  item_cards.each do |theme_card|
    next unless theme_card.respond_to? :theme_name
    theme_card.update_asset_input
  end
end

def free_skin_name
  name = "#{@theme} skin customized"
  if Card.exist?(name)
    name = "#{name} 1"
    name.next! while Card.exist?(name)
  end
  name
end

def customize_theme?
  Env.params[:customize].present? && (@theme = Env.params[:theme]).present?
end
