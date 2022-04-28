require "cardio/seed"
require "active_record/fixtures"

Cardio::Seed.load

Cardio::Migration.assume_current
Cardio::Migration::Core.assume_current
Cardio::Migration::DeckStructure.assume_current
# Cardio::Migration::Core.assume_current

# Cardio::Schema.assume_migrated_upto_version
# %i[structure deck core_cards deck_cards].each do |type|
#   Cardio::Schema.assume_migrated_upto_version type
# end

Card::Cache.reset_all

# get rid of bad constants
Card::Codename.reset_cache
Card::Codename.generate_id_constants

# TODO: explain why this is necessary
# (card:seed:update breaks without it, but I don't know why)
Cardio::Mod::Loader.load_mods
