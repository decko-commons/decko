module Decko
  # decko configuration (also see cardio/railtie)
  class Railtie < Rails::Railtie
    config.assets.enabled = false
    # config.assets.version = "1.0" # does the version matter if not enabled??

    # if false, errors that reach the controller make the app fail loudly
    # if true, errors are rescued and then error messages are rendered
    config.rescue_all_in_controller = false

    config.before_configuration do |app|
      gem_root = Decko.gem_root
      app.config.tap do |c|
        c.allow_concurrency = false
        c.filter_parameters += [:password]
        c.autoload_paths += Dir["#{gem_root}/lib"]

        c.paths.tap do |p|
          # if this directory is named lib/tasks, it will get run by decko/engine,
          # which currently breaks because of the aliases to card tasks, which
          # aren't available there.
          #
          # Ideally we'd fix that and follow the naming convention.
          p["lib/tasks"] << "#{gem_root}/lib/rake_tasks"

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
