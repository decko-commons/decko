# -*- encoding : utf-8 -*-

class AddLinkEditorToTinyMceConfig < Cardio::Migration::Core
  def up
    return unless card = Card[:tiny_mce]
    card&.update! content: card.content.sub("| link nest |", "| deckolink nest |")
  end
end
