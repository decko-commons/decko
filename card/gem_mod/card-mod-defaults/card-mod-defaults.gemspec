# -*- encoding : utf-8 -*-

require "../../../versioning"

Gem::Specification.new do |s|
  s.name = "card-mod-defaults"
  s.version = Versioning.simple

  s.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
  s.email = ["info@decko.org"]

  s.summary       = "Default decko mods"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["README.md"]

  s.required_ruby_version = ">= 2.5"
  s.metadata = { "card-mod" => "defaults" }

  %w[ace_editor prosemirror_editor recaptcha tinymce_editor markdown date].each do |mname|
    s.add_runtime_dependency "card-mod-#{mname}", Versioning.simple
  end
end
