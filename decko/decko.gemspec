# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s|
  s.name = "decko"
  s.version = s.decko_version

  s.summary = "structured wiki web platform"
  s.description =
    "a wiki approach to structured data, dynamic interaction,  and web design"

  s.files = Dir["{db,lib,public,set}/**/*"]

  s.bindir = "bin"
  s.executables = ["decko"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency "card", s.card_version
end
