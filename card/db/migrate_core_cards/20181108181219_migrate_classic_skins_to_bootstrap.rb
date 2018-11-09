class MigrateClassicSkinsToBootstrap < ActiveRecord::Migration[5.2]

  UNSUPPORTED_SKINS = %w[
    classic_skin
    customized_classic_skin
    classic_bootstrap_skin
    simple_skin
    simple_bootstrap_skin
  ].freeze

  DEFAULT_SKIN = "yeti skin".freeze

  def change
    style_rule = Card[:all, :style]
    if style_rule.item_names.first.key.in? UNSUPPORTED_SKINS
      style_rule.update_attributes! content: DEFAULT_SKIN
    end
  end
end
