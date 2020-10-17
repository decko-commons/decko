# -*- encoding : utf-8 -*-

require "rails"

Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
warn "CARD LOAD #{__LINE__}" # check
    class << self
      def inherited base
warn "C IBASE #{__LINE__} #{Rails::Engine.railtie_name}" # checko
warn "C IBASE #{__LINE__} #{find_root(base.called_from)}" # checko
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_set_load_path, base.instance)
      end
    end

    initializer :load_card_environment_config,
                before: :bootstrap, group: :all do
warn "CARD ENV #{__LINE__}" # checko
      Cardio.add_path "lib/card/config/environments", glob: "#{Rails.env}.rb"
      paths["lib/card/config/environments"].existent.each do |environment|
warn "CARD ENV #{__LINE__} #{environment}"
        require environment
      end
    end

=begin
    initializer :set_load_path do
warn "CARD #{__LINE__}"
      Cardio.set_config

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

warn "CARD PATHS #{__LINE__} #{caller[0..8]*"\n"}"
      Cardio.set_paths

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []
    end
=end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
    end
  end
end
