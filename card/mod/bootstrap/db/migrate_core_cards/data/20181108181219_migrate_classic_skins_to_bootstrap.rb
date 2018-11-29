class MigrateClassicSkinsToBootstrap < ActiveRecord::Migration[5.2]

  UNSUPPORTED_SKINS = %w[
    classic_skin
    customized_classic_skin
    classic_bootstrap_skin
    simple_skin
    simple_bootstrap_skin
  ].freeze

  DEFAULT_SKIN = "yeti skin".freeze

  UNSUPPORTED_LAYOUT = "classic_layout"

  DEFAULT_LAYOUT = "Default Layout"

  def change
    style_rule = Card[:all, :style]
    if style_rule.item_names.first.key.in? UNSUPPORTED_SKINS
      style_rule.update_attributes! content: DEFAULT_SKIN
    end

    layout_rule = Card[:all, :layout]
    if layout_rule.item_names.first.key == UNSUPPORTED_LAYOUT
      layout_rule.update_attributes! content: DEFAULT_LAYOUT
    end
  end
end
