# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "tinymce_editor"
  DeckoGem.mod_depend s, :edit

  s.summary       = "TinyMCE editor"
  s.description   = ""
  s.files         = Dir["{db,lib,public,set}/**/*"]
end
