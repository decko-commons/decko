# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    class << self
      include RailsConfigMethods

      def inherited base
        super
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end

    initializer :load_card_environment,
         before: :load_environment_config, group: :all do
      add_path "lib/card/config/environments",
               glob: "#{Rails.env}.rb", root: Cardio.gem_root
      paths["lib/card/config/environments"].existent.each do |environment|
        require environment
      end
      #config.autoloader = :zeitwerk
      #config.load_default = "6.0"
      #config.i18n.enforce_available_locales = true

      Cardio.load_card_environment
        #Cardio.load_rails_environment
    end

    def root_path_option options
      options.delete(:root) || Cardio.gem_root
    end

    initializer :connect_on_load,
         after: :load_environment_config do
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

    def add_path path, options={}
      root = root_path_option options
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end
  end
end
