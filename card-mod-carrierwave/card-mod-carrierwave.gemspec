# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "carrierwave" do |s, d|
  s.summary = "File and Image handling"
  s.description = ""
  s.add_runtime_dependency "carrierwave", "2.0.2"
  s.add_runtime_dependency "mini_magick", "~> 4.2"
  d.depends_on_mod :history
end
