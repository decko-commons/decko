# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "bar_and_box" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "bar and box views"
  s.description = ""
  d.depends_on_mod :style
end
