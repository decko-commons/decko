# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "bootstrap" do |s, d|
  s.summary = "Bootstrap"
  s.description = ""
  d.depends_on_mod :edit, :bar_and_box, :style, :script
end
