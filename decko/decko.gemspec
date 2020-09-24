# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.name          = "decko"
  s.version = DeckoGem.version
  DeckoGem.shared s

  s.summary       = "structured wiki web platform"
  s.description   = "a wiki approach to structured data, dynamic interaction, "\
                    " and web design"

  s.files         = Dir["{db,lib,public,set}/**/*"]

  s.bindir        = "bin"
  s.executables   = ["decko"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency "card", DeckoGem.card_version
end
