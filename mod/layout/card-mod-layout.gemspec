# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "layout" do |s, d|
  s.summary = "decko layouts"
  s.description = ""
  d.depends_on_mod :account, :session, :tabs
  d.required_ruby_version ">= 3.0.0"
end
