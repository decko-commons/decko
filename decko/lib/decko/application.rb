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
      end
    end

    initializer :load_decko_environment_config,
                before: :bootstrap, group: :all do
      environment=File.join( Decko.gem_root,
        "lib/decko/config/environments/#{Rails.env}.rb" )
      require environment if File.exist?(environment)
    end

    initializer :deck_autoload, before: :set_autoload_paths do |app|
      Cardio.set_paths

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

      # Add this back in green state
      config.load_defaults "6.0"    # note this isn't a setter method
      # a 6.0 default that doesn't work for history tables (super_action)
      config.active_record.belongs_to_required_by_default = false

      config.i18n.enforce_available_locales = true
      # this isn't found
      #config.active_record.raise_in_transactional_callbacks = true

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []
    end

    initializer after: :set_load_path do |app|
      app.paths.add "config/initializers", glob: "**/*.rb",
                    with: File.join(Decko.gem_root, "config/initializers")
      app.paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end
  end
end
