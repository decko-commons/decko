require "card/seed_consts"
require "active_record/fixtures"
ActiveRecord::FixtureSet.create_fixtures DECKO_SEED_PATH, DECKO_SEED_TABLES
