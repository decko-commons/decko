# -*- encoding : utf-8 -*-

require "rails"

Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    class << self
      def inherited base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_set_load_path, base.instance)
      end
    end

    initializer :load_card_environment_config,
                before: :bootstrap, group: :all do
      environment=File.join( Cardio.gem_root,
        "lib/card/config/environments/#{Rails.env}.rb" )
      require environment if File.exist?(environment)
    end

    initializer :set_load_path do
    end

    initializer :set_autoload_paths do
      Cardio.set_paths

      # any config settings below:
      # (a) do not apply to Card used outside of a Cardio context
      # (b) cannot be overridden in a deck's application.rb, but
      # (c) CAN be overridden in an environment file

      # therefore, in general, they should be restricted to settings that
      # (1) are specific to the web environment, and
      # (2) should not be overridden
      # ..and we should address (c) above!

      # general card settings (overridable and not) should be in cardio.rb
      # overridable card-specific settings are here
      # but should probably follow the cardio pattern.

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"

      config.filter_parameters += [:password]

      Cardio.set_autoload_paths
      ActiveSupport::Dependencies.autoload_paths += config.autoload_paths

      # Rails.autoloaders.log!
      Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
    end
  end
end
