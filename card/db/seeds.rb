require "cardio/seed"
require "active_record/fixtures"

ActiveRecord::FixtureSet.create_fixtures Cardio::Seed.path, Cardio::Seed::TABLES
# Cardio::Mod::Loader.load_mods
