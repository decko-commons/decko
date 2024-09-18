# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "account" do |s, d|
  s.summary = "Email-based account handling for decko cards"
  s.description = ""
  d.depends_on_mod :email, :permissions, :list, :integrate, :edit
  d.required_ruby_version ">= 3.0.0"
  d.required_ruby_version ">= 3.0.0"
end
