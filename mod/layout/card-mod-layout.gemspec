# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "layout" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "decko layouts"
  s.description = ""
  d.depends_on_mod :account, :session, :tabs
end
