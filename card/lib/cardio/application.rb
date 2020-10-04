# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio/application_record'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application

    def configure &block
      super do
        instance_eval &block if block_given?
        # connect actual app instance to Cardio mattr
      end
    end

    class << self
      def inherited base
        super

        Rails.app_class = base
        Cardio.application= base.instance
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end

    initializer :card_load_config,
                before: :load_environment_config do
      Cardio.load_card_environment
    end

    initializer :card_load_config_initializers,
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
