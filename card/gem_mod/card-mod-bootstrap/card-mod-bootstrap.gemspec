# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "bootstrap"
  DeckoGem.depends_on_mod s, :edit

  s.summary = "Bootstrap"
  s.description = ""
end
