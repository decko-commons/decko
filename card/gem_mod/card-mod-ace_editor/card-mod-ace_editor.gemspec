# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "ace_editor"
  DeckoGem.depends_on_mod s, "edit"

  s.summary = "Ace editor"
  s.description = ""
end
