# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio'
#require 'config/environment'
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
    initializer :load_card_environment_config,
                before: :load_environment_config, group: :all do
      add_path paths, "lib/card/config/environments", glob: "#{Rails.env}.rb", root: Cardio.gem_root
      paths["lib/card/config/environments"].existent.each do |environment|
        require environment
      end
    end

    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def add_path paths, path, options={}
      root = options.delete(:root) || Cardio.gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
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

    def paths
      @paths ||= begin
        paths = super
        Cardio.set_paths paths

        paths
      end
    end
  end
end
