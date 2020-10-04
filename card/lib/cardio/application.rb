# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio/application_record'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    class << self
      def inherited base
        super

        Rails.app_class = base
        Cardio.application= base.instance
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end

    def configure &block
      super do
        instance_eval &block if block_given?

        config.autoloader = :zeitwerk
        config.load_default = "6.0"
        config.i18n.enforce_available_locales = true

        config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]
      end
    end

    initializer :load_card_config,
                before: :load_environment_config do
      Cardio.load_card_environment
    end

    initializer :load_card_config_initializers,
                after: :load_environment_config do
      Cardio.load_rails_environment
        paths["config/initializers"].existent.sort.each do |initializer|
          load(initializer)
        end
      Cardio.connect_on_load
    end

    initializer :card_connect_on_load, after: :application_record do
      #Cardio.connect_on_load
    end
  end
end
