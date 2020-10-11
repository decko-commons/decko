# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application

    initializer before: :set_autoload_paths do
      Cardio.autoload_paths
    end

    initializer before: :set_load_path do
      Cardio.default_configs
      #Rails.autoloaders.log!
     # Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))

      #ActiveSupport.run_load_hooks(:before_configuration)
      #ActiveSupport.run_load_hooks(:load_active_record)
    end

    ENVCONF = "lib/card/config/environments"

    initializer :load_config_initializers do
      paths.add "config/initializers", glob: "**/*.rb",
          with: File.join(Cardio.gem_root, "lib/card/config/initializers")
      paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    initializer before: :load_environment_config do
      path = File.join(Cardio.gem_root, ENVCONF, "#{Rails.env}.rb")
      paths.add ENVCONF, with: path, glob: "#{Rails.env}.rb"
      paths[ENVCONF].existent.each do |environment|
        require environment
      end
    end

    initializer :connect_on_load, after: :load_active_suport do
      ActiveSupport.run_load_hooks(:before_card)
      ActiveSupport.on_load(:active_record) do
        Cardio.connect_on_load
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
      end
    end
  end
end
