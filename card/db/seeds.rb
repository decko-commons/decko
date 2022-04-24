require "cardio/seed"
require "active_record/fixtures"

ActiveRecord::FixtureSet.create_fixtures Cardio::Seed.path, Cardio::Seed::TABLES

# TODO: explain why this is necessary
Cardio::Mod::Loader.load_mods
