# -*- encoding : utf-8 -*-

require "../../../versioning"

Gem::Specification.new do |s|
  s.name = "card-mod-markdown"
  s.version = Versioning.simple

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "markdown support for decko"
  s.description   = "use markdown in decko card content"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["{db,set}/**/*.rb"]

  s.required_ruby_version = ">= 2.5"
  s.metadata = { "card-mod" => "markdown" }

  s.add_runtime_dependency "card", Versioning.card
  s.add_runtime_dependency "kramdown"
end
