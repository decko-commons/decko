# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "carrierwave"

  s.summary = "File and Image handling"
  s.description = ""
  s.add_runtime_dependency "carrierwave", "2.0.2"
  s.add_runtime_dependency "mini_magick", "~> 4.2"
end
