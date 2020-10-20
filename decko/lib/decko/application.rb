# -*- encoding : utf-8 -*-

require "rails/railtie"
require "cardio/application"
require "decko/engine"

Bundler.require :default, *Rails.groups

module Decko

  class Application < Cardio::Application
    class << self
      def inherited base
        Rails.app_class = base

        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_load_environment_config, base.instance)
      end
    end

    initializer :load_decko_environment_config,
                before: :bootstrap, group: :all do
      Cardio.add_path "lib/decko/config/environments", glob: "#{Rails.env}.rb"
      paths["lib/decko/config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :deck_autoload, before: :set_autoload_paths do |app|
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

      config.load_defaults "6.0"    # note this isn't a setter method
      config.autoloader = :zeitwerk # 6.0 includes this setting
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
  end
end
