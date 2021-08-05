module Decko
  # decko configuration
  # also see cardio/railtie
  class Railtie < Rails::Railtie
    config.assets.enabled = false
    config.assets.version = "1.0" # does the version matter if not enabled??

    config.before_configuration do |app|
      app.config.allow_concurrency = false
      app.config.filter_parameters += [:password]
      app.config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      paths = app.config.paths

      paths["config/environments"].unshift "#{Decko.gem_root}/config/environments"

      unless paths["config/routes.rb"].existent.present?
        paths["config/routes.rb"] << "#{Decko.gem_root}/config/application_routes.rb"
      end
    end
  end
end
