unless defined? DECKO_SEED_TABLES
  DECKO_SEED_TABLES = %w( cards card_actions card_acts card_changes
                         card_references ).freeze
end

unless defined? DECKO_SEED_PATH
  DECKO_SEED_PATH = File.join(
    ENV["DECKO_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "new"
  )
end
