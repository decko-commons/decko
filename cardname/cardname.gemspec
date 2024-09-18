# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "cardname" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.description = "Naming patterns abstracted from Decko cards"
  s.summary = "Card names without all the cards"

  s.files = Dir[
    "README.md",
    "Rakefile",
    "lib/**/*"
  ]

  s.add_dependency "activesupport", d.rails_version
  s.add_dependency "htmlentities", "~> 4.3"
end
