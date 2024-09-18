# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "edit" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.summary = "Edit handling"
  s.description = ""
  d.depends_on_mod :rules, :list

end
