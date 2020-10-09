# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?
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

  module RailsConfigMethods
    # FIXME: use in Deck, Engine, etc.
    def root
      Rails.root
    end

    def application
     Rails.application
    end

    def config
      application.config
    end

    def paths
      application.paths
    end
  end

  class << self
    include RailsConfigMethods

    def gem_root
      CARD_GEM_ROOT
    end

    def card_defined?
      const_defined? "Card"
    end

    def load_card?
      ActiveRecord::Base.connection && !card_defined?
    rescue
      false
    end

    def cache
      @cache ||= ::Rails.cache
    end

    def default_configs
      {
        read_only: read_only?,

        # if you disable inline styles tinymce's formatting options stop working
        allow_inline_styles: true,

        delaying: nil,

        recaptcha_public_key: nil, # deprecated; use recaptcha_site_key instead
        recaptcha_private_key: nil, # deprecated; use recaptcha_secret_key instead
        recaptcha_proxy: nil,
        recaptcha_site_key: nil,
        recaptcha_secret_key: nil,
        recaptcha_minimum_score: 0.5,

        override_host: nil,
        override_protocol: nil,

        no_authentication: false,
        files_web_path: "files",

        max_char_count: 200,
        max_depth: 20,
        email_defaults: nil,

        token_expiry: 2.days,
        acts_per_page: 10,
        space_last_in_multispace: true,
        closed_search_limit: 10,
        paging_limit: 20,

        non_createable_types: [%w[signup setting set session bootswatch_skin customized_bootswatch_skin]], # FIXME
        view_cache: false,
        rss_enabled: false,
        double_click: :signed_in,

        encoding: "utf-8",
        request_logger: false,
        performance_logger: false,
        sql_comments: true,

        file_storage: :local,
        file_buckets: {},
        file_default_bucket: nil,
        protocol_and_host: nil,

        rich_text_editor: :tinymce,

        persistent_cache: true,
        prepopulate_cache: false,
        machine_refresh: :cautious, # options: eager, cautious, never
        compress_javascript: true,

        allow_irreversible_admin_tasks: false,
        raise_all_rendering_errors: false,
        rescue_all_in_controller: true,
        navbox_match_start_only: true,

        load_strategy: :eval,
        cache_set_module_list: false
      }.each_pair do |setting, value|
        set_default_value(config, setting, *value)
      end
    end

    def autoload_paths
      config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]

      [gem_root, root].each do |dir|
        Dir[File.join(Cardio.gem_root}, dir, "mod")] do |mod|
          autoload_and_watch config, mod
        end
      end
      gem_mod_specs.each_value do |spec|
        autoload_and_watch config, spec.full_gem_path
      end

      #add_path "mod",         # add card gem's mod path
      #paths["mod"] << "mod" # add deck's mod path
    end

    # set_clear_dependencies_hook -- use as initializer hook?
    # the watchable_dirs are processes in set_clear_dependencies_hook
    # hook in the railties gem in finisher.rb
    def autoload_and_watch config, mod_path
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
    end

    def read_only?
      !ENV["DECKO_READ_ONLY"].nil?
    end

    # In production mode set_config gets called twice.
    # The second call overrides all deck config settings
    # so don't change settings here if they already exist
    def set_default_value config, setting, *value
      config.send("#{setting}=", *value) unless config.respond_to? setting
    end

    def set_load_path
      %w[set set_pattern].each do |path|
        tmppath = "tmp/#{path}"
        add_path tmppath, root: root unless paths[tmppath]&.existent
      end

      add_db_paths
      add_initializer_paths
      add_mod_initializer_paths
    end

    def load_card_configuration
      default_configs

      Rails.autoloaders.log!
     # Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))

      ActiveSupport.run_load_hooks(:before_configuration)
      ActiveSupport.run_load_hooks(:load_active_record)
      ActiveSupport.run_load_hooks(:before_card)
    end

    def connect_on_load
      ActiveSupport.on_load(:before_configure_environment) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      ActiveSupport.on_load(:after_initialize) do
      end
      ActiveSupport.on_load(:after_application_record) do
        #ActiveSupport.run_load_hooks :initialize, self
      end
    end

    def add_path path, options={}
      root = options.delete(:root) || gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

  private

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

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end
  end
end
