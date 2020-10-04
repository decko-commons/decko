# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        super # super is Cardio::App
      end
    end

    def configure &block
      super do

        instance_eval &block if block_given?

        #paths = config.paths
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

        config.autoloader = :zeitwerk
        config.load_default = "6.0"
        config.i18n.enforce_available_locales = true

        config.allow_concurrency = false
        config.assets.enabled = false
        config.assets.version = "1.0"

        yield config if block_given?

        config.filter_parameters += [:password]

        config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

        #ActiveSupport.run_load_hooks :before_configuration, app

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
      paths.add PATH, with: PATH, glob: "#{Rails.env}.rb", root: Decko.gem_root
    end

    initializer :decko_load_config,
                after: :load_card_config do
      paths[PATH].existent.each do |environment|
        require environment
      end
    end
  end
end
