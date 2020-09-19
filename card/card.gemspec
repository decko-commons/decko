# -*- encoding : utf-8 -*-

require "../versioning"

Gem::Specification.new do |s|
  s.name = "card"
  s.version = Versioning.card

  s.authors = [ "Ethan McCutchen", "Philipp Kühl", "Lewis Hoffman", "Gerry Gleason" ]
  s.email = ["info@decko.org"]

  s.summary = "a simple engine for emergent data structures"
  s.description =
    "Cards are wiki-inspired data atoms." \
    'Card "Sharks" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."
  s.homepage = "http://decko.org"
  s.licenses = ["GPL-2.0", "GPL-3.0"]

  s.files = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                "{config,db,lib,mod,tmpsets}/**/*"]

  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.5"

  [
    ["cardname",                    Versioning.simple],

    # card modules in decko core gems:
    ["card-mod-date",               Versioning.simple],
    ["card-mod-edit",               Versioning.simple],
    ["card-mod-ace_editor",         Versioning.simple],
    ["card-mod-prosemirror_editor", Versioning.simple],
    ["card-mod-tinymce_editor",     Versioning.simple],
    ["card-mod-recaptcha",          Versioning.simple],

    ["haml",                        "~> 5.0"], # markup language used in view API
    ["jwt",                         "~> 2.2"], # used in token.rb
    ["uuid",                        "~> 2.3"], # universally unique identifier.
                                              # used in temporary names
    ["colorize",                    "~> 0.8"], # livelier cli outputs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE TO MODS?


    # files and images
    ["carrierwave",                 "2.0.2"],
    ["mini_magick",                 "~> 4.2"],

    # assets (JavaScript, CSS, etc)
    ["coderay",                     "~> 1.1"],
    ["sassc",                       "~> 2.0"],
    ["coffee-script",               "~> 2.4"],
    ["uglifier",                    "~> 3.2"],
    ["sprockets",                   "~> 3.7"], # sprockets 4 requires new configuration

    # pagination
    ["kaminari",                    "~> 1.0"],
    ["bootstrap4-kaminari-views",   "~> 1.0"],

    # other
    ["diff-lcs",                    "~> 1.3"], # content diffs in histories
    ["recaptcha",                   "~> 4.13.1"],
    ["twitter",                     "~> 6.1"], # for event-based integration
    ["delayed_job_active_record",   "~> 4.1"],
    ["activerecord-import",         "~> 1.0"],
    ["card-mod-markdown",           "~> 0.4"],
    ["msgpack",                     "~> 1.3"],

    ["rake",                        "<= 12.3.0"],
    ["rails",                       "~> 6"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
