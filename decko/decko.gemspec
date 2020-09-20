# -*- encoding : utf-8 -*-

require "../versioning"

Gem::Specification.new do |s|
  s.name          = "decko"
  s.version       = Versioning.simple
  s.authors       = ["Ethan McCutchen", "Philipp Kühl", "Lewis Hoffman", "Gerry Gleason"]
  s.email         = ["info@decko.org"]

  #  s.date          = '2013-12-20'
  s.summary       = "structured wiki web platform"
  s.description   = "a wiki approach to structured data, dynamic interaction, "\
                    " and web design"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["README.rdoc", "LICENSE", "GPL",
                        "{app,bin,lib,rails,script}/**/*"]

  s.bindir        = "bin"
  s.executables   = ["decko"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.5"

  [["card", Versioning.card]].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
