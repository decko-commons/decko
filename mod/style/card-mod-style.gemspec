# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "style" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "Skins, CSS, SCSS, etc"
  s.description = ""
  d.depends_on_mod :assets, :list
end
