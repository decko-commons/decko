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
    ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "a simple engine for emergent data structures"
  s.description   =
    "Cards are wiki-inspired data atoms." \
    '"Carditects" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = `git ls-files`.split $INPUT_RECORD_SEPARATOR

  # add submodule files (seed data)
  morepaths = `git submodule --quiet foreach pwd`.split $OUTPUT_RECORD_SEPARATOR
  morepaths.each do |submod_path|
    gem_root = File.expand_path File.dirname(__FILE__)
    relative_submod_path = submod_path.gsub "#{gem_root}/", ""
    Dir.chdir(submod_path) do
      morefiles = `git ls-files`.split $OUTPUT_RECORD_SEPARATOR
      s.files += morefiles.map do |filename|
        "#{relative_submod_path}/#{filename}"
      end
    end
  end

  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.2.2"

  [
    ["cardname",                   version],
    ["haml",                       "~> 5.0"],

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE TO MODS?

    # files and images
    ["carrierwave",                "~> 1.1"],
    ["mini_magick",                "~> 4.2"],

    # text formatting
    ["htmlentities",               "~> 4.3"],

    # content diffs in histories
    ["diff-lcs",                   "~> 1.3"],

    ["recaptcha",                  "~> 4.3"],

    # assets (JavaScript, CSS, etc)
    ["coderay",                    "~> 1.1"],
    ["sass",                       "~> 3.4"],
    ["coffee-script",              "~> 2.4"],
    ["uglifier",                   "~> 3.2"],

    # pagination
    ["kaminari",                   "~> 1.0"],
    ["bootstrap4-kaminari-views",  "~> 1.0"],

    # needed for event-based twitter integration
    ["twitter",                    "6.1.0"],

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # REMOVE?

    # not really used?
    ["uuid",                       "~> 2.3"],

    # mime-types can be removed if we drop support for ruby 1.9.3
    # mime-types 3.0 uses mime-types-data which isn't compatible with 1.9.3
    ["mime-types",                 "2.99.1"],

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE? to dev section of Gemfiles

    # testing
    ["nokogiri",                   "1.8"],

    # rake tasks
    ["colorize",                   "0.8"]


  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
