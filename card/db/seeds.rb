require "cardio/seed"
require "active_record/fixtures"

Cardio::Seed.load

Card::Cache.reset_all

# get rid of bad constants
Card::Codename.reset_cache
Card::Codename.generate_id_constants

# TODO: explain why this is necessary
# (card:seed:update breaks without it)
# I think it has something to do with Card being partially loaded by the
# ActiveRecord::FixtureSet handling in Cardio::Seed.load, but if that's the case
# this might not be a complete enough fix.
Cardio::Mod::Loader.load_mods
