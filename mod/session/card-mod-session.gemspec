# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "session" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "session"
  s.description = ""
  d.depends_on_mod :list
end
