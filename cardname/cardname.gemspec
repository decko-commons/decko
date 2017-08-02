
version = File.open(File.expand_path("../../card/VERSION", __FILE__)).read.chomp

Gem::Specification.new do |s|
  s.name = "cardname"
  s.version = version

  s.require_paths = ["lib"]

  s.authors = ["Gerry Gleason", "Ethan McCutchen", "Philipp Kühl"]
  s.email = "info@decko.org"

  s.description = "Naming patterns abstracted from Decko cards"
  s.summary = "Card names without all the cards"

  s.extra_rdoc_files = [ "README.rdoc" ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
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
  s.licenses = ["GPL-2","GPL-3"]
  s.rdoc_options =
    ["--main", "README.rdoc", "--inline-source", "--line-numbers"]


  s.add_dependency "activesupport"
  s.add_dependency "htmlentities"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "bundler"
end

