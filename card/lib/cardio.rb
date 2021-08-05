# -*- encoding : utf-8 -*-

require "cardio/delaying"

ActiveSupport.on_load :after_card do
  Cardio::Mod.load
end

module Cardio
  extend Delaying

  class << self
    delegate :application, :root, to: :Rails
    delegate :config, :paths, to: :application

    def gem_root
      @gem_root ||= File.expand_path "..", __dir__
    end

    def card_defined?
      const_defined? "Card"
    end

    def load_card?
      ActiveRecord::Base.connection && !card_defined?
    rescue StandardError
      false
    end

    def load_card!
      require "card"
      ActiveSupport.run_load_hooks :after_card
    end

    def cache
      @cache ||= ::Rails.cache
    end

    def database
      @database ||= config.database_configuration.dig Rails.env, "database"
    end
  end
end
