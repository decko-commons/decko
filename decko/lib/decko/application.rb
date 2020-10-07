# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"

Bundler.require :default, *Rails.groups

module Decko
  class Application < Cardio::Application
    PATH = "lib/decko/config/environments"
    initializer :load_decko_environment_config,
                before: :load_environment_config, group: :all do
      set_paths
      add_path paths, PATH, glob: "#{Rails.env}.rb"
      paths[PATH].existent.each do |environment|
        require environment
      end
    end

    class << self
      include Cardio::RailsConfigMethods

      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def add_path paths, path, options={}
      root = options.delete(:root) || Decko.gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    initializer :decko_configure, before: :load_environment_config do
      #Decko::Engine.configure
      config.load_default = "6.0"

      config.active_job.queue_adapter = :delayed_job

      # any config settings below:
      # (a) do not apply to Card used outside of a Decko context
      # (b) cannot be overridden in a deck's application.rb, but
      # (c) CAN be overridden in an environment file

      # therefore, in general, they should be restricted to settings that
      # (1) are specific to the web environment, and
      # (2) should not be overridden
      # ..and we should address (c) above!

      # general card settings (overridable and not) should be in cardio.rb
      # overridable decko-specific settings don't have a place yet
      # but should probably follow the cardio pattern.

      config.i18n.enforce_available_locales = true

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"
      # config.active_record.raise_in_transactional_callbacks = true

      config.filter_parameters += [:password]

      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      #ActiveSupport.run_load_hooks :before_configuration, app
      # Rails.autoloaders.log!
      #Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
      # paths configuration

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []

      unless paths["config/routes.rb"].existent.present?
        Cardio.add_path "config/routes.rb",
                 with: "rails/application-routes.rb"
      end

    end

    #def paths
    def set_paths
      Cardio.set_paths paths

    initializer :decko_load_environment,
                before: :load_card_environment do
      path = File.join(Decko.gem_root, PATH, "#{Rails.env}.rb")
      paths.add PATH, with: path
      paths[PATH].existent.each do |environment|
        require environment
      end
    end
  end
end
