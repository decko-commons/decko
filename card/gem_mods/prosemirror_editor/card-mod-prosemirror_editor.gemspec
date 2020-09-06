# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-prosemirror_editor"
  s.version = "0.1"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "Calendar editor"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                        "{config,db,lib,set}/**/*"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "prosemirror_editor" }
  s.add_runtime_dependency "card-mod-edit", "~> 0.1"
end
