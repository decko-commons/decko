# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "prosemirror_editor"
  DeckoGem.depends_on_mod s, :edit

  s.summary = "Prose Mirror editor"
  s.description = ""
end
