  # -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "script" do |s, d|
  s.summary = "JavaScript, CoffeeScript, etc."
  s.description = ""
  d.depends_on_mod :assets, :list
end
