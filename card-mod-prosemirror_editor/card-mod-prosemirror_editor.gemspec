# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "prosemirror_editor"
  s.depends_on_mod :edit
  s.summary = "Prose Mirror editor"
  s.description = ""
end
