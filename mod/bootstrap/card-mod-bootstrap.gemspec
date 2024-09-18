# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "bootstrap" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "Bootstrap"
  s.description = ""
  d.depends_on_mod :edit, :bar_and_box, :style, :script

end
