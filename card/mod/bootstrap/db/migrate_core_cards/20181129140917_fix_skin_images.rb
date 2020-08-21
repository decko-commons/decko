
require_relative "lib/skin"

class FixSkinImages < ActiveRecord::Migration[5.2]
  def change
    Card::Auth.as_bot do
      Skin.themes.each do |theme_name|
        Skin.new(theme_name).update_thumbnail
      end
    end
  end
end
