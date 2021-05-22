# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "cardname" do |s, _d|
  s.description = "Naming patterns abstracted from Decko cards"
  s.summary = "Card names without all the cards"

  s.files = Dir[
    "README.md",
    "Rakefile",
    "lib/**/*"
  ]

  s.add_dependency "activesupport", "~> 6"
  s.add_dependency "htmlentities",  "~> 4.3"
end
