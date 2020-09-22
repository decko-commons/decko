# -*- encoding : utf-8 -*-

require "../../../versioning"

Gem::Specification.new do |s|
  s.name = "card-mod-multicard"
  s.version = Versioning.simple

  s.authors = ["Gerry Gleason"]
  s.email = ["info@decko.org"]

  s.summary       = "A multi deck access concept"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                        "{config,db,lib,set}/**/*"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "multideck" }
end
