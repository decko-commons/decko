# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "help" do |s, d|
  s.summary = "card help text and guides"
  s.description = ""
  d.depends_on_mod :markdown, :permissions
  d.required_ruby_version ">= 3.0.0"
end
