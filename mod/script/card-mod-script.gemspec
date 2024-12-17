# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "script" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "JavaScript, CoffeeScript, etc."
  s.description = ""
  d.depends_on_mod :assets, :list
end
