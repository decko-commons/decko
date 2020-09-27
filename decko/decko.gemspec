# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko" do |s, d|
  s.summary = "structured wiki web platform"
  s.description =
    "a wiki approach to structured data, dynamic interaction,  and web design"

  s.files = Dir["{db,lib,public,set}/**/*"]

  s.bindir = "bin"
  s.executables = ["decko"]
  s.add_runtime_dependency "card", d.card_version
end
