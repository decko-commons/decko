# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "comment" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "card comments"
  s.description = ""
  d.depends_on_mod :permissions
end
