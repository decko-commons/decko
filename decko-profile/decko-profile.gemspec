# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-profile" do |s, d|
  s.summary = "decko and card mod profiling"
  s.description = ""

  d.depends_on "ruby-prof"
end
