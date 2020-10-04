# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
require 'rails'
require "cardio/modfiles"
require "cardio/schema"
require "cardio/utils"
require 'active_support'

ActiveSupport.on_load :after_card do
warn "CARDIO0 #{__LINE__} ol after_card Mod.load"
  require 'cardio/mod'
  Cardio::Mod.load
end

module Cardio
  extend Schema
  extend Utils
  extend Modfiles
  CARD_GEM_ROOT = File.expand_path("..", __dir__)

  mattr_accessor :config, :paths

  class << self
    def application= app
warn "CONFIGO1 #{__LINE__} change app= #{@@config} PATHSO #{@@paths} app= #{app}" unless @@config.nil?
      @@config = app.config
      @@paths = app.paths
warn "CONFIGO2 #{__LINE__} app= #{@@config} PATHSO #{@@paths} app= #{app}"
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

    def set_default_configs
warn "CARDIO3 #{__LINE__} set_default_configs"
      defaults = {
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
        eager_load: false,

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
      cfg = config
warn "CONFIGO4 #{__LINE__} #{cfg}"
      defaults.each_pair do |setting, value|
        # so don't change settings here if they already exist
        cfg.send("#{setting}=", *value) unless cfg.respond_to? setting
      end
warn "CONFIGO5 #{__LINE__} eager #{cfg.eager_load}"
    end

    def add_lib_dirs_to_autoload_paths
warn "CONFIGO6 #{__LINE__} #{config}"
warn "PATHSO7 #{__LINE__} #{paths}"
warn "CARDIO8 AUTOLOAD add paths #{Dir["#{gem_root}/lib"]}"
      config.autoload_paths += Dir["#{gem_root}/lib"]
#warn "dirs #{config.autoload_paths.map(&:to_s)*', '}"

      # TODO: this should use each_mod_path, but it's not available when this is run
      # This means libs will not get autoloaded (and sets not watched) if the mod
      # dir location is overridden in config
      [gem_root, root].each { |dir| autoload_and_watch "#{dir}/mod/*" }
      gem_mod_specs.each_value { |spec| autoload_and_watch spec.full_gem_path }

      # the watchable_dirs are processes in
      # set_clear_dependencies_hook hook in the railties gem in finisher.rb
    end

    def autoload_and_watch mod_path
#warn "CONFIGO #{__LINE__} AL&watch #{config} #{mod_path}/lib &W/set"
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
    end

    def read_only?
      !ENV["DECKO_READ_ONLY"].nil?
    end

    def paths_init
raise "PI twice shouldn't happen" if @pathinit
@pathinit = true
warn "PATHSO10 #{paths} #{__LINE__}:#{__FILE__}"
      add_path "tmp/set", root: root
      add_path "tmp/set_pattern", root: root

      add_path "mod"        # add card gem's mod path
      paths["mod"] << "mod" # add deck's mod path

      add_db_paths
      add_initializer_paths
      add_mod_initializer_paths
warn "PATHSO11 #{paths} #{__LINE__} paths init #{paths["config/initializers"].map(&:to_s)*"\n"}"
    end

    def root
      config.root
    end

    def gem_root
      CARD_GEM_ROOT
    end

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end

    def load_card_environment
      add_lib_dirs_to_autoload_paths
warn "CARDIO12 #{__LINE__} #{config} load card config defaults\n"#{caller[0..12]*"\n"}"
      set_default_configs
      paths_init
      add_configs

      ActiveSupport.run_load_hooks(:before_configuration)
      ActiveSupport.run_load_hooks(:load_active_record)
      ActiveSupport.run_load_hooks(:before_card)

warn "PATHSO13 #{paths} #{__LINE__} load card env #{self} #{config} #{paths}"
      add_path "lib/card/config/environments", glob: "#{Rails.env}.rb", root: Cardio.gem_root
    end

    def load_rails_environment
      paths["lib/card/config/environments"].existent.each do |environment|
warn "CARDIO14 #{__LINE__} load env #{environment}"
        require environment
      end
    end

    def connect_on_load
warn "CARDIOa.2.15 #{__LINE__} set onload AppR"
      ActiveSupport.on_load(:before_configure_environment) do
warn "CARDIOa.2.17 #{__LINE__} onload AR" #{caller[0..10]*"\n"}"
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      ActiveSupport.on_load(:after_initialize) do
warn "CARDIOa.2.18 #{__LINE__} aft init #{self}"
      end
      ActiveSupport.on_load(:after_application_record) do
warn "CARDIOa.2.19 #{__LINE__}load ap rec trig, load card #{self}"
        #ActiveSupport.run_load_hooks :initialize, self
      end
warn "CARDIOa.2.16 #{__LINE__}s et onload done"
    end

    def add_configs
warn "CONFIGO20 #{__LINE__} #{config}"

warn "CONFIGO21 #{__LINE__} current #{config.autoloader}"
      config.autoloader = :zeitwerk
      config.load_default = "6.0"
      config.i18n.enforce_available_locales = true
warn "current #{config.autoloader}"

      Rails.autoloaders.log!
warn "CARDIO22 AUTOLOADERS #{Rails.autoloaders} #{Rails.autoloaders.main} #{File.join(Cardio.gem_root, "lib/card/seed_consts.rb")}"
     # Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
    end
  private

    def add_path path, options={}
      root = options.delete(:root) || Cardio.gem_root
      options[:with] = File.join(root, (options[:with] || path))
warn "PATHSO23 #{paths} #{__LINE__} add cfinit path #{path}, #{options}" if path == 'config/initializers'
      paths.add path, options
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
warn "PATHSO24 #{paths} #{__LINE__} add init #{base_dir} #{path_mark} #{initializers_dir}" unless mod 
        paths[path_mark] << initializers_dir
      end
    end
  end
end
