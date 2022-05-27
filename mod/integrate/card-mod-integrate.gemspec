# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "integrate" do |s, d|
  s.summary = "card configurable integration events"
  s.description = ""
  d.depends_on_mod :rules
end
