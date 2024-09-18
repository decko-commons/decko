# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "search" do |s, d|
  s.summary = "search"
  s.description = ""
  d.depends_on_mod :collection, :format, :help
  d.required_ruby_version ">= 3.0.0"
end
