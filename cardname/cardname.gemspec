# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "cardname" do |s, _d|
  s.description = "Naming patterns abstracted from Decko cards"
  s.summary = "Card names without all the cards"

  s.require_paths = ["lib"]
  s.files = [
    "README.md",
    "Rakefile",
    "lib/core_ext.rb",
    "lib/cardname.rb",
    "lib/cardname/contextual.rb",
    "lib/cardname/manipulate.rb",
    "lib/cardname/parts.rb",
    "lib/cardname/predicates.rb",
    "lib/cardname/variants.rb"
  ]

  s.add_dependency "activesupport", "~> 6"
  s.add_dependency "htmlentities",  "~> 4.3"
end

