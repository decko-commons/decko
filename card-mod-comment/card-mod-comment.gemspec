# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "comment" do |s, d|
  s.summary = "card comments"
  s.description = ""
  d.depends_on_mod :permissions
end
