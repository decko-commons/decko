# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "date"

  s.summary       = "Calendar editor"
  s.description   = ""
  s.files         = Dir["{db,lib,set}/**/*"]
end
