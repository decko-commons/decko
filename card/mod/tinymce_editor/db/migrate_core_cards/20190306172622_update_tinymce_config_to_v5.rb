# -*- encoding : utf-8 -*-

class UpdateTinymceConfigToV5 < Card::Migration::Core
  def up
    content = Card[:tiny_mce].content.sub('"modern"', '"silver"')
    ensure_card :tiny_mce, content: content
  end
end
