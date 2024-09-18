# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-profile" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "decko and card mod profiling"
  s.description = ""

  d.depends_on ["ruby-prof", "~> 1.4"]
end
