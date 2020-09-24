# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "ace_editor"
  DeckoGem.mod_depend s, "edit"

  s.summary       = "Calendar editor"
  s.description   = ""
  s.files         = Dir["{db,lib,public,set}/**/*"]
end
