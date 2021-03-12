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
  extend I18n
  CARD_GEM_ROOT = File.expand_path("..", __dir__)

  mattr_reader :paths, :config

  class << self
    def card_defined?
      const_defined? "Card"
    end

    def load_card?
      ActiveRecord::Base.connection && !card_defined?
    rescue
      false
    end

    def load_card!
      require "card"
      ActiveSupport.run_load_hooks :after_card
    end

    def cache
      @cache ||= ::Rails.cache
    end

    # TODO: many of these defaults should be in mods!
    def default_configs
      defaults_from_yaml.merge(
        read_only: !ENV["DECKO_READ_ONLY"].nil?,
        load_strategy: (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)
      )
    end

    def defaults_from_yaml
      filename = File.expand_path "cardio/defaults.yml", __dir__
      YAML.load_file filename
    end

    def set_config config
      @@config = config

      add_lib_dirs_to_autoload_paths config

      default_configs.each_pair do |setting, value|
        set_default_value(config, setting, *value)
      end
    end

    def add_lib_dirs_to_autoload_paths config
      config.autoload_paths += Dir["#{gem_root}/lib"]

      # TODO: this should use each_mod_path, but it's not available when this is run
      # This means libs will not get autoloaded (and sets not watched) if the mod
      # dir location is overridden in config
      [gem_root, root].each { |dir| autoload_and_watch config, "#{dir}/mod/*" }
      gem_mod_specs.each_value { |spec| autoload_and_watch config, spec.full_gem_path }

      # the watchable_dirs are processes in
      # set_clear_dependencies_hook hook in the railties gem in finisher.rb

      # TODO: move this to the right place in decko
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
    end

    def autoload_and_watch config, mod_path
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
    end

    # In production mode set_config gets called twice.
    # The second call overrides all deck config settings
    # so don't change settings here if they already exist
    def set_default_value config, setting, *value
      config.send("#{setting}=", *value) unless config.respond_to? setting
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

    def root
      @@config.root
    end

    def gem_root
      CARD_GEM_ROOT
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
