# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "bootstrap"
  s.depends_on_mod :edit
  s.summary = "Bootstrap"
  s.description = ""
end
