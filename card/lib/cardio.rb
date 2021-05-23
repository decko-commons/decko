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

  mattr_reader :paths

  class << self
    delegate :application, :root, to: :Rails
    delegate :config, to: :application

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

    def set_paths paths
      @@paths = paths

      add_tmppaths
      add_path "mod"        # add card gem's mod path
      paths["mod"] << "mod" # add deck's mod path

      add_db_paths
      add_initializer_paths
      add_mod_initializer_paths
    end

    def add_tmppaths
      %w[set set_pattern].each do |dir|
        opts = tmppath_opts dir
        add_path "tmp/#{dir}", opts if opts
      end
    end

    def tmppath_opts dir
      if ENV["REPO_TMPSETS"]
        { with: "tmpsets/#{dir}" }
      elsif ENV["TMPSETS"]
        { root: root }
      end
    end

    def add_db_paths
      add_path "db"
      add_path "db/migrate"
      add_path "db/migrate_core_cards"
      add_path "db/migrate_deck", root: root, with: "db/migrate"
      add_path "db/migrate_deck_cards", root: root, with: "db/migrate_cards"
      add_path "db/seeds.rb", with: "db/seeds.rb"
    end

    def add_initializer_paths
      add_path "config/initializers", glob: "**/*.rb"
      add_initializers root
      each_mod_path { |mod_path| add_initializers mod_path, false, "core_initializers" }
    end

    def add_mod_initializer_paths
      add_path "mod/config/initializers", glob: "**/*.rb"
      each_mod_path { |mod_path| add_initializers mod_path, true }
    end

    def add_initializers base_dir, mod=false, init_dir="initializers"
      Dir.glob("#{base_dir}/config/#{init_dir}").each do |initializers_dir|
        path_mark = mod ? "mod/config/initializers" : "config/initializers"
        paths[path_mark] << initializers_dir
      end
    end



    def add_path path, options={}
      root = options.delete(:root) || gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end
  end
end
