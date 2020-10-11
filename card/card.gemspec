# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "card" do |s, d|
  s.version = d.card_version

  s.summary = "a simple engine for emergent data structures"
  s.description =
    "Cards are wiki-inspired data atoms." \
    'Card "Sharks" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."

  s.files = Dir["VERSION", "README.md", "LICENSE", "GPL",
                "{exe,config,db,lib,mod}/**/*"]

  s.bindir        = "exe"
  s.executables   = ["card"]

  d.depends_on(
    ["cardname",             d.decko_version],
    ["rake",                     "<= 12.3.0"],
    ["rails",                         "~> 6"],
    ["uuid",                        "~> 2.3"], # universally unique identifier.
    ["colorize",                    "~> 0.8"], # livelier cli outputs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE TO MODS?
    # card-mod-format
    ["haml",                        "~> 5.0"], # markup language used in view API
    # card-mod-account
    ["jwt",                         "~> 2.2"], # used in token.rb
                                               # used in temporary names
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
    ["activerecord-import",         "~> 1.0"]
  )
end
