# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "integrate" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "card configurable integration events"
  s.description = ""
  d.depends_on_mod :rules
end
