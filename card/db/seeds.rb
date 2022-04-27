require "cardio/seed"
require "active_record/fixtures"

Card::Cache.reset_all

Cardio::Seed.load

# get rid of bad constants
Card::Codename.reset_cache
Card::Codename.generate_id_constants

# TODO: explain why this is necessary
# (card:seed:update breaks without it, but I don't know why)
Cardio::Mod::Loader.load_mods
