require "card/seed_consts"
require "active_record/fixtures"
ActiveRecord::FixtureSet.create_fixtures CARD_SEED_PATH, CARD_SEED_TABLES
Cardio::Mod::Loader.load_mods
