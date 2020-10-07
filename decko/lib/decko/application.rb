# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"

Bundler.require :default, *Rails.groups

module Decko
  class Application < Cardio::Application
    PATH = "lib/decko/config/environments"
    initializer :load_decko_environment_config,
                before: :load_environment_config, group: :all do
      add_path paths, PATH, glob: "#{Rails.env}.rb"
      paths[PATH].existent.each do |environment|
        require environment
      end
    end

    class << self
      def inherited base
        super # super is Cardio::App
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end

    # override in each domain with local root
    def root_path option
      root = options.delete(:root) || Decko.gem_root
    end

    def configure &block
      super do
        config.load_default = "6.0"

        instance_eval &block if block_given?

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

        config.filter_parameters += [:password]

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
    end

    PATH = "lib/decko/config/environments"

    initializer :decko_config_path,
                before: :load_environment_config do
      path = File.join(Decko.gem_root, PATH, "#{Rails.env}.rb")
      paths.add PATH, with: path
    end

    initializer :decko_load_config,
                after: :load_card_config do
      paths[PATH].existent.each do |environment|
        require environment
      end
    end
  end
end
