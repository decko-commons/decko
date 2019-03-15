# -*- encoding : utf-8 -*-

class UpdateTinymceConfigToV5 < Card::Migration::Core
  DEPRECATED_PLUGINS = %w[contextmenu textcolor colorpicker].freeze

  def up
    content = Card[:tiny_mce].content.sub('"modern"', '"silver"')
    content = remove_deprecated_plugins(content)
    ensure_card :tiny_mce, content: content
  end

  def remove_deprecated_plugins content
    content.sub(/['"]plugins['"]:
                 \s*
                 ['"](?<plugins>[^"']+)["']
                 (?<comma>,)?
                 $/x) do |_match|
      comma = Regexp.last_match[:comma]
      plugins = Regexp.last_match[:plugins].split(/\s+/) - DEPRECATED_PLUGINS
      %("plugins": "#{plugins.join ' '}"#{comma})
    end
  end
end
