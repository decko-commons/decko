# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "ace_editor"
  s.depends_on_mod "edit"
  s.summary = "Ace editor"
  s.description = ""
end
