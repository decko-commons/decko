# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "ace_editor" do |s, d|
  s.summary = "Ace editor"
  s.description = ""
  d.depends_on_mod :edit, :script
  d.required_ruby_version ">= 3.0.0"
end
