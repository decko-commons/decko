# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s, d|
  d.mod "bootstrap"
  d.depends_on_mod :edit
  s.summary = "Bootstrap"
  s.description = ""
end
