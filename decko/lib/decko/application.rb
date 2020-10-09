# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"

Bundler.require :default, *Rails.groups

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
        Rails.app_class = base
      end
    end

    initializer before: :load_config_initializers do
      paths.add "config/initializers", glob: "**/*.rb",
          with: File.join(Decko.gem_root, "lib/decko/config/initializers")
    end

    initializer before: :set_autoload_paths do
      paths.add "lib", root: Decko.gem_root
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
    end

    initializer before: :set_load_path do
      config.load_defaults "6.0"
      paths.add "lib", root: Decko.gem_root
      Cardio.set_load_path

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

      # Rails.autoloaders.log!
      Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
      # paths configuration

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []
    end

    initializer :application_routes, before: :add_routing_paths do
      unless paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb", with: "rails/application-routes.rb"
      end
    end

    PATH = "lib/decko/config/environments"
    initializer :application_routes do
      path = File.join(Decko.gem_root, PATH, "#{Rails.env}.rb")
      paths.add PATH, with: path
      paths[PATH].existent.each do |environment|
        require environment
      end
    end
  end
end
