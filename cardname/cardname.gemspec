# -*- encoding : utf-8 -*-

version = File.open(File.expand_path("../../card/VERSION", __FILE__)).read.chomp

Gem::Specification.new do |s|
  s.name = "cardname"
  s.version = version
  s.require_paths = ["lib"]

  s.homepage      = "http://decko.org"
  s.authors = [ "Ethan McCutchen", "Philipp Kühl", "Gerry Gleason" ]
  s.email = "info@decko.org"

  s.description = "Naming patterns abstracted from Decko cards"
  s.summary = "Card names without all the cards"

  s.extra_rdoc_files = [ "README.rdoc" ]
  s.files = [
    "README.rdoc",
    "Rakefile",
    "lib/core_ext.rb",
    "lib/cardname.rb",
    "lib/cardname/contextual.rb",
    "lib/cardname/manipulate.rb",
    "lib/cardname/parts.rb",
    "lib/cardname/predicates.rb",
    "lib/cardname/variants.rb"
  ]
  s.licenses = ["GPL-2.0","GPL-3.0"]
  s.rdoc_options =
    ["--main", "README.rdoc", "--inline-source", "--line-numbers"]


  s.add_dependency "activesupport", "~> 6"
  s.add_dependency "htmlentities",  "~> 4.3"

  s.required_ruby_version = ">= 2.5"

  #s.add_development_dependency "rspec"
  #s.add_development_dependency "rdoc"
  #s.add_development_dependency "bundler"
end

