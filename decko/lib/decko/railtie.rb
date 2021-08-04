module Decko
  # decko configuration
  # also see cardio/railtie
  class Railtie < Rails::Railtie
    config.allow_concurrency = false
    config.assets.enabled = false
    config.assets.version = "1.0"

    config.before_configuration do |app|
      app.config.filter_parameters += [:password]
      app.config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      paths = app.config.paths

      paths.add "decko/config/environments",
                with: File.join(Decko.gem_root, "config/environments"),
                glob: "#{Rails.env}.rb"

      paths.add "decko/config/initializers",
                with: File.join(Decko.gem_root, "config/initializers"),
                glob: "**/*.rb"

      if paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb",
                  with: File.join(Decko.gem_root, "rails/application-routes.rb")
      end
    end
  end
end
