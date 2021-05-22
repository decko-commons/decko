source "http://rubygems.org"

gem "decko", path: "./"
gem "card-mod-defaults", path: "./mod"

# DATABASE
# Decko currently supports MySQL (best tested), PostgreSQL (well tested), and SQLite
# (not well tested).
gem "mysql2"

# WEBSERVER
# To run a simple deck at localhost:3000, you can use thin (recommended), unicorn,
# or (Rails" default) Webrick
gem "thin"
# gem "unicorn"

# CARD MODS
# The easiest way to change card behaviors is with card mods. To install a mod:
#
#   1. add `gem "card-mod-MODNAME"` below
#   2. run `bundle update` to install the code
#   3. run `decko update` to make any needed changes to your deck
#
# The "defaults" includes a lot of functionality that is needed in standard decks.
gem "card-mod-defaults"

# BACKGROUND
# A background gem is needed to run tasks like sending notifications in a background
# process.
# See https://github.com/decko-commons/decko/tree/master/card-mod-delayed_job
# for additional configuration details.
gem "card-mod-delayed_job"

# MONKEYS
# You can also create your own mods. Mod developers (or "Monkeys") will want some
# additional gems to support development and testing.
gem "card-mod-monkey", group: :development
gem "decko-cucumber", group: :test
gem "decko-cypress", group: %i[cypress test]
gem "decko-profile", group: :profile
gem "decko-rspec", group: :test
gem "decko-spring", group: %i[test development]

# PLATYPUSES
# This mod is strongly recommended for platypuses – coders working on the decko core
gem "card-mod-platypus", group: :test

# The following allows simple (non-gem) mods to specify gems via a Gemfile.
# You may need to alter this code if you move such mods to an unconventional location.
Dir.glob("mod/**/Gemfile").each { |gemfile| instance_eval File.read(gemfile) }
