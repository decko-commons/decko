# -*- encoding : utf-8 -*-

class ScriptRuleUseMods < Cardio::Migration
  MODS = %w[
    script ace_editor bootstrap date prosemirror tinymce_editor rules
  ].freeze

  def up
    card = Card[:all, :script]
    MODS.each do |mod|
      card.add_item "mod: #{mod}+*script"
    end
    card.save!
  end
end
