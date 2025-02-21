# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "edit" do |s, d|
  s.summary = "Edit handling"
  s.description = ""
  d.depends_on_mod :rules, :list
end
