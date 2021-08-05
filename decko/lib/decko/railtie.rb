module Decko
  # decko configuration
  # also see cardio/railtie
  class Railtie < Rails::Railtie
    initializer "decko.load_environment_config",
                after: "card.load_environment_config", group: :all do |app|
      app.config.paths["decko/config/environments"].existent.each do |environment|
        require environment
      end
    end

    config.assets.enabled = false
    config.assets.version = "1.0" # does the version matter if not enabled??

    config.before_configuration do |app|
      app.config.allow_concurrency = false
      app.config.filter_parameters += [:password]
      app.config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      paths = app.config.paths

      paths.add "decko/config/environments",
                with: File.join(Decko.gem_root, "config/environments"),
                glob: "#{Rails.env}.rb"

      if paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb",
                  with: File.join(Decko.gem_root, "rails/application-routes.rb")
      end
    end
  end
end
