# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "assets" do |s, d|
  s.summary = "decko asset pipeline"
  s.description = ""
  d.depends_on_mod :machines, :content
end
