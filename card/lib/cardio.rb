# -*- encoding : utf-8 -*-

require "active_support"
require "active_support/core_ext/module/delegation"
require "cardio/delaying"

ActiveSupport.on_load :after_card do
  Cardio::Mod.load
end

# Cardio is a quick loading module and is at the heart (get it?) of
# card loading and configuration because it is useful long before the Card class is
# (or card objects are)
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

    def mods
      Mod.dirs.mods
    end

    def with_config tmp
      keep = tmp.keys.each_with_object({}) { |k, h| h[k] = config.send k }
      tmp.each { |k, v| config.send "#{k}=", v }
      yield
    ensure
      keep.each { |k, v| config.send "#{k}=", v }
    end
  end
end
