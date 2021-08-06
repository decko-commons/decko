module Decko
  # decko configuration (also see cardio/railtie)
  class Railtie < Rails::Railtie
    config.assets.enabled = false
    # config.assets.version = "1.0" # does the version matter if not enabled??

    config.before_configuration do |app|
      gem_root = Decko.gem_root
      app.config.tap do |c|
        c.allow_concurrency = false
        c.filter_parameters += [:password]
        c.autoload_paths += Dir["#{gem_root}/lib"]

        c.paths.tap do |p|
          p["lib/tasks"].unshift "#{gem_root}/lib/decko/tasks"

          p["config/environments"].unshift "#{gem_root}/config/environments"
          p["config/initializers"].unshift "#{gem_root}/config/initializers"

          unless p["config/routes.rb"].existent.present?
            p["config/routes.rb"] << "#{gem_root}/config/application_routes.rb"
          end
        end
      end
    end
  end
end
