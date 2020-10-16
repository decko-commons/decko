# -*- encoding : utf-8 -*-

require "rails/railtie"
require "decko/engine"
require_relative "config/initializers/sedate_parser"

Bundler.require :default, *Rails.groups

module Decko

  class Application < Rails::Application
    class << self
      def inherited base
        #super
        Rails.app_class = base

        add_lib_to_load_path!(find_root(base.called_from))
        add_lib_to_load_path!(Cardio.gem_root)
        ActiveSupport.run_load_hooks(:before_set_load_path, base.instance)
        ActiveSupport.run_load_hooks(:before_load_environment_config, base.instance)
      end
    end

    initializer :load_decko_environment_config,
                before: :load_environment_config, group: :all do
      Cardio.add_path "lib/decko/config/environments", glob: "#{Rails.env}.rb"
      paths["lib/decko/config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :set_load_path do
      Cardio.set_config

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

      # config.load_defaults "6.0"
      config.autoloader = :zeitwerk
      config.load_default = "6.0"
      config.i18n.enforce_available_locales = true
      # config.active_record.raise_in_transactional_callbacks = true

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"

      config.filter_parameters += [:password]

      # Rails.autoloaders.log!
      Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))

      Cardio.set_paths

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
    end
  end
end
