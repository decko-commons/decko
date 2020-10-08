# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    extend RailsConfigMethods

    ENVCONF = "lib/card/config/environments"

    initializer :autoload_paths, before: :set_autoload_paths do
      Cardio.add_lib_dirs_to_autoload_paths
    end

    initializer :card_configuration, before: :set_load_path do
      Cardio.load_card_configuration
      #config.autoloader = :zeitwerk
      #config.load_default = "6.0"
      #config.i18n.enforce_available_locales = true
    end

    initializer :card_environment, before: :load_environment_hook do
      path = File.join(Cardio.gem_root, ENVCONF, "#{Rails.env}.rb")
      paths.add ENVCONF, with: path
      paths[ENVCONF].existent.each do |environment|
        require environment
      end
    end

    initializer :connect_on_load, after: :load_active_suport do
      ActiveSupport.on_load(:active_record) do
        Cardio.connect_on_load
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
      end
      # ActiveSupport.on_load(:after_initialize) do
      #   # require "card" if Cardio.load_card?
      #   Card if Cardio.load_card?
      # rescue ActiveRecord::StatementInvalid => e
      #  ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
      # end
    end
  end
end
