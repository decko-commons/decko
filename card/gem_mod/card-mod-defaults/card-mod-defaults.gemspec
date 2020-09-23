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

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "defaults" }

  [
    ["card-mod-ace_editor",         Versioning.simple],
    ["card-mod-prosemirror_editor", Versioning.simple],
    ["card-mod-recaptcha",          Versioning.simple],
    ["card-mod-tinymce_editor",     Versioning.simple],
    ["card-mod-date",               Versioning.simple]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
