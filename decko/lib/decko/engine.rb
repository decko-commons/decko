
require "rails/all"
require "cardio"

# TODO: Move these to modules that use them
require "htmlentities"
require "coderay"
require "haml"
require "kaminari"
require "bootstrap4-kaminari-views"
require "diff/lcs"
require "builder"

require "decko"

module Decko
  class Engine < ::Rails::Engine

    engine_name = :decko_engine

    def load_task_dir dir
      paths.add "lib/tasks", with: dir, glob: "**/*.rake"
    end

    rake_tasks do
      load_task_dir ::Cardio.gem_root
    end
    load_tasks

    rake_tasks do
      load_task_dir ::Decko.gem_root
    end

    initializer :set_autoload_paths, group: :all do
      config.autoload_paths = Cardio.config.autoload_paths
    end

    initializer :set_autoload_paths, group: :all do
      config.autoload_paths = Cardio.config.autoload_paths
    end

    initializer before: :set_load_path do
      Rails.autoloaders.main.ignore(File.join(Decko.gem_root, "lib/rails/*-routes.rb"))

      paths.add "app/controllers",  with: "lib/rails/controllers", eager_load: true
      paths.add "gem-assets",       with: "lib/rails/assets"

      paths.add "config/routes.rb", with: "lib/rails/engine-routes.rb"
      unless paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb", with: "lib/rails/application-routes.rb"
      end
    end

    initializer "decko.engine.load_config_initializers",
                after: :load_config_initializers do
      paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end
  end
end
