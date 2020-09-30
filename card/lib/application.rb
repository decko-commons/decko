# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio'
require 'application_record'

Bundler.require :default, *Rails.groups

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(assets: %w[development test cypress])
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

class Card < ApplicationRecord
  class Application < Rails::Application
    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
        ActiveSupport.run_load_hooks(:load_active_record, base.instance)
      end
    end

    initializer :load_card_environment_config,
                after: :bootstrap, group: :all do
                #before: :load_environment_config, group: :all do
      add_path paths, "lib/card/config/environments", glob: "#{Rails.env}.rb", root: Cardio.gem_root
      paths["lib/card/config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        c=ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
      #   # require "card" if Cardio.load_card?
      #   Card if Cardio.load_card?
      # rescue ActiveRecord::StatementInvalid => e
      #  ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
      # end
    end
    def config
      @config ||= begin
        config = super

        Cardio.set_config config

        config.autoloader = :zeitwerk
        config.load_default = "6.0"
        config.i18n.enforce_available_locales = true

        config
      end
    end

    def add_path paths, path, options={}
      root = options.delete(:root) || Cardio.gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    def paths
      @paths ||= begin
        paths = super
        Cardio.set_paths paths

        paths
      end
    end
  end
end

ActiveSupport.run_load_hooks :after_application_record, self
