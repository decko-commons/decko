unless defined? CARD_SEED_TABLES
  CARD_SEED_TABLES = %w( cards card_actions card_acts card_changes
                         card_references ).freeze
end

unless defined? CARD_SEED_PATH
  CARD_SEED_PATH = File.join(
    ENV["CARD_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "new"
  )
end

unless defined? CARD_TEST_SEED_PATH
  CARD_TEST_SEED_PATH = File.join(Cardio.gem_root, "db", "seed", "test", "fixtures")
end
