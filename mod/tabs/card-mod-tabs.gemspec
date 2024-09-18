# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "tabs" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.summary = "tabs"
  s.description = ""
  d.depends_on_mod :bootstrap
end
