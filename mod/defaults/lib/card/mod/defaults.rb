
fixtures_dir = File.join File.dirname(__FILE__), "../../..", "data/fixtures"

Cardio::Railtie.config.before_configuration do |app|
  app.config.paths["seed_fixtures"] << fixtures_dir
end
