# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "email" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.summary = "Email handling"
  s.description = ""
  d.depends_on_mod :search, :list, :permissions
end
