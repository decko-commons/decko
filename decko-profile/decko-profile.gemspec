# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-profile" do |s, _d|
  s.summary = "decko and card mod profiling"
  s.description = ""

  s.add_runtime_dependency "ruby-prof"
end
