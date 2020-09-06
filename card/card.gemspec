# -*- encoding : utf-8 -*-

version = File.open(File.expand_path("../VERSION", __FILE__)).read.chomp
vbits = version.split('.').map &:to_i
vplus = { 0 => 90, 1 => 100 } # can remove and hardcode after 1.0
vminor = vplus[ vbits[0] ] + vbits[1]
card_version = [1, vminor, vbits[2]].compact.map(&:to_s).join "."
# Because card was already at 1.21 when wagn was renamed to decko and decko's
# versioning went back to 0.X, card's versioning is now a little funny.
# For now decko 0.X.Y will map to card 1.(90+X).Y, and decko 1.X.Y will map to
# card 1.(100+X).Y. Things will get much simpler after 2.0, when decko X.Y.Z
# will map to card X.Y.Z.


Gem::Specification.new do |s|
  s.name = "card"
  s.version = card_version

  s.authors =
    [ "Ethan McCutchen", "Philipp Kühl", "Lewis Hoffman", "Gerry Gleason" ]
  s.email = ["info@decko.org"]

  s.summary       = "a simple engine for emergent data structures"
  s.description   =
    "Cards are wiki-inspired data atoms." \
    '"Carditects" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                        "{config,db,lib,mod,tmpsets}/**/*"]

  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.5"

  [
    ["cardname",                   version],

    # card modules in decko core gems:
    ["card-mod-date",              "~>0.1"],
    ["card-mod-edit",              "~>0.1"],
    ["card-mod-ace_editor",        "~>0.1"],
    ["card-mod-prosemirror_editor", "~>0.1"],
    ["card-mod-tinymce_editor",    "~>0.1"],

    ["haml",                       "~> 5.0"], # markup language used in view API
    ["jwt",                        "~> 2.2"], # used in token.rb
    ["uuid",                       "~> 2.3"], # universally unique identifier.
                                              # used in temporary names
    ["colorize",                   "~> 0.8"], # livelier cli outputs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE TO MODS?


    # files and images
    ["carrierwave",                 "2.0.2"],
    # ["fog",                           "2.1"], # can be removed after carrierwave upgrade
    ["mini_magick",                "~> 4.2"],

    # assets (JavaScript, CSS, etc)
    ["coderay",                    "~> 1.1"],
    ["sassc",                      "~> 2.0"],
    ["coffee-script",              "~> 2.4"],
    ["uglifier",                   "~> 3.2"],
    ["sprockets",                  "~> 3.7"], # sprockets 4 requires new configuration

    # pagination
    ["kaminari",                   "~> 1.0"],
    ["bootstrap4-kaminari-views",  "~> 1.0"],

    # other
    ["diff-lcs",                   "~> 1.3"], # content diffs in histories
    ["recaptcha",                  "~> 4.13.1"],
    ["twitter",                    "~> 6.1"], # for event-based integration
    ["delayed_job_active_record",  "~> 4.1"],
    ["activerecord-import",        "~> 1.0"],
    ["card-mod-markdown",          "~> 0.4"],
    ["msgpack",                    "~> 1.3"],

    ["rake",                       "<= 12.3.0"],
    ["rails",                      "~> 6"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
