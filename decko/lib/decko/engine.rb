
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
warn "DENG PATHS #{__LINE__}"
    end
warn "DENG PATHS #{__LINE__}"
    load_tasks

    rake_tasks do
      load_task_dir ::Decko.gem_root
warn "DENG PATHS #{__LINE__}"
    end
warn "DENG PATHS #{__LINE__}"

    initializer :set_autoload_paths, group: :all do
      config.autoload_paths = Cardio.config.autoload_paths
warn "DENG #{__LINE__} #{config.autoload_paths.map(&:to_s)}"
warn "DENG #{__LINE__} #{Cardio.config.autoload_paths.map(&:to_s)}"
    end

    initializer :set_autoload_paths, group: :all do
      config.autoload_paths = Cardio.config.autoload_paths
    end

    initializer before: :set_load_path do
      Rails.autoloaders.main.ignore(File.join(Decko.gem_root, "lib/rails/*-routes.rb"))

warn "DENG PATHS #{__LINE__}"
      paths.add "app/controllers",  with: "rails/controllers", eager_load: true
      paths.add "gem-assets",       with: "rails/assets"

      paths.add "config/routes.rb", with: "rails/engine-routes.rb"
      unless paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb", with: "rails/application-routes.rb"
      end
    end

    initializer "decko.engine.load_config_initializers",
                after: :load_config_initializers do
warn "DENG INITS #{__LINE__}"
      paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end
  end
end
