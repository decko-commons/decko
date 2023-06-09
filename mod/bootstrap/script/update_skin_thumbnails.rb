# -*- encoding : utf-8 -*-

require_relative "../data/transform/lib/skin"

puts "Updating bootstrap themes ..."
Skin.themes.each do |theme_name|
  puts theme_name
  Skin.new(theme_name).update_thumbnail
end
