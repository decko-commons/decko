# -*- encoding : utf-8 -*-

version = File.open(File.expand_path("../../../../card/VERSION", __FILE__)).read.chomp
# see card.gemspec for explanation of all of this, which has been ham-handedly
# cut and pasted here.

Gem::Specification.new do |s|
  s.name = "card-mod-ace_editor"
  s.version = version

  s.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
  s.email = ["info@decko.org"]

  s.summary       = "Calendar editor"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                        "{config,db,lib,set}/**/*"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "ace_editor" }
  s.add_runtime_dependency "card-mod-edit", version
end
