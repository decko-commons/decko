# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "bar_and_box" do |s, d|
  s.summary = "bar and box views"
  s.description = ""
  d.depends_on_mod :style
end
