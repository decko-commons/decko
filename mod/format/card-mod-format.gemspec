# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "format" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "format"
  s.description = ""
  # d.depends_on ["truncato", "~> 0.7"] # truncates html strings
  d.depends_on_mod :content
end
