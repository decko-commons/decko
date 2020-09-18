# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?
require "cardio/schema.rb"
require "cardio/utils.rb"

ActiveSupport.on_load :after_card do
  Card::Mod.load
end

module Cardio
  extend Schema
  extend Utils
  CARD_GEM_ROOT = File.expand_path("..", __dir__)

  mattr_reader :paths, :config

  class << self
    def card_defined?
      const_defined? "Card"
    end

    def load_card?
      # ARDEP: connection object
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

    def default_configs
      {
        read_only: read_only?,

        # if you disable inline styles tinymce's formatting options stop working
        allow_inline_styles: true,

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
      }
    end

    def set_config config
      @@config = config
      config.active_job.queue_adapter = :delayed_job # better place for this?

      add_lib_dirs_to_autoload_paths config

      default_configs.each_pair do |setting, value|
        set_default_value(config, setting, *value)
      end
    end

    def add_lib_dirs_to_autoload_paths config
      config.autoload_paths += Dir["#{gem_root}/lib"]
      config.autoload_paths += Dir["#{gem_root}/mod/*/lib"]
      config.watchable_dirs["#{gem_root}/mod/*/set"] = [:rb]

      config.autoload_paths += Dir["#{root}/mod/*/lib"]
      config.watchable_dirs["#{root}/mod/*/set"] = [:rb]
      gem_mod_paths.each do |_mod_name, mod_path|
        config.autoload_paths += Dir["#{mod_path}/lib"]
        config.watchable_dirs["#{mod_path}/set"] = [:rb]
      end
      # the watachable_dirs are processes in
      # set_clear_dependencies_hook hook in the railties gem in finisher.rb

      # TODO: move this to the right place in decko
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
      # config.autoload_paths += Dir["#{gem_root}/lib/**/"]
      # config.autoload_paths += Dir["#{gem_root}/mod/*/lib/**/"]
      # config.autoload_paths += Dir["#{root}/mod/*/lib/**/"]
      # gem_mod_paths.each do |_mod_name, mod_path|
      #  config.autoload_paths += Dir["#{mod_path}/lib/**/"]
      # end
    end

    # @return Hash with key mod names (without card-mod prefix) and values the
    #   full path to the mod
    def gem_mod_paths
      @gem_mods ||=
        Bundler.definition.specs.each_with_object({}) do |gem_spec, h|
          mod_name = mod_name_from_gem_spec gem_spec
          next unless mod_name

          h[mod_name] = gem_spec.full_gem_path
        end
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

    def set_paths paths
      @@paths = paths
      add_path "tmp/set", root: root
      add_path "tmp/set_pattern", root: root

      add_path "mod"        # add card gem's mod path
      paths["mod"] << "mod" # add deck's mod path

      add_db_paths
      add_initializer_paths
      add_mod_initializer_paths
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
      each_mod_path do |mod_path|
        add_initializers mod_path, false, "core_initializers"
      end
    end

    def add_mod_initializer_paths
      add_path "mod/config/initializers", glob: "**/*.rb"
      each_mod_path do |mod_path|
        add_initializers mod_path, true
      end
    end

    def add_initializers base_dir, mod=false, init_dir="initializers"
      Dir.glob("#{base_dir}/config/#{init_dir}").each do |initializers_dir|
        path_mark = mod ? "mod/config/initializers" : "config/initializers"
        paths[path_mark] << initializers_dir
      end
    end

    def each_mod_path
      paths["mod"].each do |mods_path|
        Dir.glob("#{mods_path}/*").each do |single_mod_path|
          yield single_mod_path
        end
      end
      gem_mod_paths.each do |_mod_name, mod_path|
        yield mod_path
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

    def migration_paths type
      list = paths["db/migrate#{schema_suffix type}"].to_a
      case type
      when :core_cards
        list += mod_migration_paths "migrate_core_cards"
      when :deck_cards
        list += mod_migration_paths "migrate_cards"
      when :deck
        list += mod_migration_paths "migrate"
      end
      list.flatten
    end

    def mod_migration_paths dir
      [].tap do |list|
        Card::Mod.dirs.each("db/#{dir}") { |path| list.concat Dir.glob path }
      end
    end

    private

    def mod_name_from_gem_spec gem_spec
      if (m = gem_spec.name.match(/^card-mod-(.+)$/))
        m[1]
      else
        gem_spec.metadata["card-mod"]
      end
    end
  end
end
