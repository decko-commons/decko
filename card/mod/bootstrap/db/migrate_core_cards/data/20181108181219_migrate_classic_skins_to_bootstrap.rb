# fix sites still using no-longer supported skins and layouts
class MigrateClassicSkinsToBootstrap < ActiveRecord::Migration[5.2]
  UNSUPPORTED_SKINS = %w[
    classic_skin
    customized_classic_skin
    classic_bootstrap_skin
    simple_skin
    simple_bootstrap_skin
  ].freeze

  DEFAULT_SKIN = "yeti skin".freeze

  UNSUPPORTED_LAYOUT = "classic_layout".freeze

  DEFAULT_LAYOUT = "Default Layout".freeze

  def change
    style_rule = Card[:all, :style]
    if style_rule.first_name.key.in? UNSUPPORTED_SKINS
      style_rule.update! content: DEFAULT_SKIN
    end

    layout_rule = Card[:all, :layout]
    return unless layout_rule.first_name.key == UNSUPPORTED_LAYOUT
    layout_rule.update! content: DEFAULT_LAYOUT
  end
end
