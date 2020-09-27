# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "profile" do |s, _d|
  s.summary = "card mod profiling"
  s.description = ""

  s.add_runtime_dependency "ruby-prof"
end
