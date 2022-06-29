include_set Abstract::AssetOutputter, output_format: :css, output_view: :compressed

assign_type :pointer

def ok_to_read
  true
end

def make_asset_output_coded
  super Cardio.config.seed_mods.first
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

  def input_type
    :box_select
  end

  def default_item_view
    :bar
  end

  # view :input, template: :haml

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

def joined_items_content
  item_cards.map(&:content).compact.join "\n"
end

event :update_theme_input, :finalize,
      before: :update_asset_output_file, changed: :content do
  item_cards.each do |theme_card|
    next unless theme_card.respond_to? :theme_name
    theme_card.update_asset_input
  end
end

event :validate_item_type, :validate, on: :save, before: :validate_asset_inputs, changed: :content do
  item_cards.each do |item|
    next if %i[css scss].include? item.type_code

    errors.add :content, t(:style_invalid_item_type, item: item.name, type: item.type)
  end
end
