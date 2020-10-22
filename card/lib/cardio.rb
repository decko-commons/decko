# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
require "cardio/schema"
require "cardio/utils"
require "cardio/modfiles"
require "cardio/delaying"

ActiveSupport.on_load :after_card do
  Card::Mod.load
end

module Cardio
  extend Schema
  extend Utils
  extend Modfiles
  extend Delaying
  CARD_GEM_ROOT = File.expand_path("..", __dir__)

  module CardClassMethods
    def application
      Rails.application
    end

    def config
      application.config
    end

    def paths
      application.paths
    end

    def root
      config.root
    end

    def card_defined?
      const_defined? "Card"
    end

    def load_card?
      ActiveRecord::Base.connection && !card_defined?
    rescue
      false
    end
  end

  class << self
    include CardClassMethods

    def gem_root
      CARD_GEM_ROOT
    end

    def cache
      @cache ||= ::Rails.cache
    end
  end
end
