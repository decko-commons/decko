# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s, d|
  d.mod "prosemirror_editor"
  d.depends_on_mod :edit
  s.summary = "Prose Mirror editor"
  s.description = ""
end
