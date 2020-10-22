# -*- encoding : utf-8 -*-

require "rails"

Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    class << self
      def inherited base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_set_load_path, base.instance)
      end
    end

    initializer :load_card_environment_config,
                before: :bootstrap, group: :all do
      environment=File.join( Cardio.gem_root,
        "lib/card/config/environments/#{Rails.env}.rb" )
      require environment if File.exist?(environment)
    end

    initializer :set_load_path do
    end

    initializer :set_autoload_paths do
      set_paths

      # any config settings below:
      # (a) do not apply to Card used outside of a Cardio context
      # (b) cannot be overridden in a deck's application.rb, but
      # (c) CAN be overridden in an environment file

      # therefore, in general, they should be restricted to settings that
      # (1) are specific to the web environment, and
      # (2) should not be overridden
      # ..and we should address (c) above!

      # general card settings (overridable and not) should be in cardio.rb
      # overridable card-specific settings are here
      # but should probably follow the cardio pattern.

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"

      config.filter_parameters += [:password]

      set_autoload_paths
      ActiveSupport::Dependencies.autoload_paths += config.autoload_paths

      # Rails.autoloaders.log!
      Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
    end

    def read_only?
      !ENV["DECKO_READ_ONLY"].nil?
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

        google_analytics_key: nil,

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

        load_strategy: (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval),
        cache_set_module_list: false
      }.each_pair do |setting, *value|
        config.send("#{setting}=", *value) unless config.respond_to? setting
      end
    end

    def set_autoload_paths
      config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]

      [Cardio.gem_root, root].each { |dir| autoload_and_watch "#{dir}/mod/*" }
      Cardio.gem_mod_specs.each_value { |spec| autoload_and_watch spec.full_gem_path }
    end

    # the watchable_dirs are processed in
    # set_clear_dependencies_hook hook in the railties gem in finisher.rb
    def autoload_and_watch mod_path
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
    end

    def set_paths
      default_configs

      %w[set set_pattern].each do |path|
        tmppath = "tmp/#{path}"
        add_path tmppath, root: root unless paths[tmppath]&.existent
      end

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
      Cardio.each_mod_path { |mod_path| add_initializers mod_path, false, "core_initializers" }
    end

    def add_mod_initializer_paths
      add_path "mod/config/initializers", glob: "**/*.rb"
      Cardio.each_mod_path { |mod_path| add_initializers mod_path, true }
    end

    def add_initializers base_dir, mod=false, init_dir="initializers"
      Dir.glob("#{base_dir}/config/#{init_dir}").each do |initializers_dir|
        path_mark = mod ? "mod/config/initializers" : "config/initializers"
        paths[path_mark] << initializers_dir
      end
    end

    def add_path path, options={}
      root = options.delete(:root) || Cardio.gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end
  end
end
