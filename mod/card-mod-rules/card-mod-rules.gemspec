# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "rules" do |s, d|
  s.summary = "rules"
  s.description = ""
  d.depends_on_mod :format, :search
end
