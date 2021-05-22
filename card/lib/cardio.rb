# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
require "cardio/schema"
require "cardio/utils"
require "cardio/modfiles"
require "cardio/delaying"

ActiveSupport.on_load :after_card do
  Cardio::Mod.load
end

module Cardio
  extend Schema
  extend Utils
  extend Modfiles
  extend Delaying
  CARD_GEM_ROOT = File.expand_path("..", __dir__)

  class << self
    delegate :root, :application, to: :Rails
    delegate :config, :paths, to: :application

    def gem_root
      CARD_GEM_ROOT
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

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end
  end
end
