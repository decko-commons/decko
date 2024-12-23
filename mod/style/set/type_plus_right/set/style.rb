include_set Abstract::AssetOutputter, output_format: :css, output_view: :compressed

assign_type :pointer

def ok_item_types
  %i[css scss skin bootswatch_skin]
end

def ok_to_read?
  true
end

def make_asset_output_coded
  super(Cardio.config.seed_mods.first)
end

format do
  # turn off autodetection of uri's
  def chunk_list
    :references
  end
end

HIDDEN_SKINS = %w[bootstrap_default_skin themeless_bootstrap_skin bootstrap_default_skin
                  classic_bootstrap_skin].freeze

format :html do
  view :stylesheet_path, cache: :never, perms: :none do
    if params[:debug] == "style"
      path mark: card.name, item: :import, format: :css
    else
      card.asset_output_url
    end
  end

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
