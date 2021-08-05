module Cardio
  # primary railtie for cards
  class Railtie < Rails::Railtie
    # if you disable inline styles tinymce's formatting options stop working
    config.allow_inline_styles = true
    config.delaying = nil
    config.token_expiry = 2.days

    config.recaptcha_public_key = nil  # deprecated; use recaptcha_site_key instead
    config.recaptcha_private_key = nil # deprecated; use recaptcha_secret_key instead

    config.recaptcha_proxy = nil
    config.recaptcha_site_key = nil
    config.recaptcha_secret_key = nil
    config.recaptcha_minimum_score = 0.5

    config.google_analytics_key = nil

    config.override_host = nil
    config.override_protocol = nil

    config.no_authentication = false
    config.files_web_path = "files"

    config.max_char_count = 200
    config.max_depth = 20
    config.email_defaults = nil

    config.acts_per_page = 10
    config.space_last_in_multispace = true
    config.closed_search_limit = 10
    config.paging_limit = 20

    config.non_createable_types = %w[
      signup
      setting
      set
      session
      bootswatch_skin
      customized_bootswatch_skin
    ]

    config.view_cache = false
    config.rss_enabled = false
    config.double_click = :signed_in

    config.encoding = "utf-8"
    config.request_logger = false
    config.performance_logger = false
    config.sql_comments = true

    config.file_storage = :local
    config.file_buckets = {}
    config.file_default_bucket = nil
    config.protocol_and_host = nil

    config.rich_text_editor = :tinymce

    config.persistent_cache = true
    config.prepopulate_cache = false
    config.machine_refresh = :cautious
    config.compress_javascript = true

    config.allow_irreversible_admin_tasks = false
    config.raise_all_rendering_errors = false
    config.rescue_all_in_controller = true
    config.navbox_match_start_only = true

    config.cache_set_module_list = false

    config.i18n.enforce_available_locales = true
    config.read_only = !ENV["DECKO_READ_ONLY"].nil?
    config.load_strategy = ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval

    # TODO: support mod-specific railties

    config.before_configuration do |app|
      card_root = Cardio.gem_root

      app.config.autoloader = :zeitwerk
      app.config.autoload_paths += Dir["#{card_root}/lib"]

      paths = app.config.paths
      paths["config/environments"].unshift "#{card_root}/config/environments"

      paths["config/initializers"] << "#{card_root}/config/initializers"
      paths.add "late/initializers", glob: "**/*.rb"

      paths.add "mod", with: "#{card_root}/mod"
      paths["mod"] << "mod"
      paths.add "files"

      paths.add "db", with: "#{card_root}/db"
      paths.add "db/seeds.rb", with: "#{card_root}/db/seeds.rb"
      paths.add "db/migrate", with: "#{card_root}/db/migrate"
      paths.add "db/migrate_core_cards", with: "#{card_root}/db/migrate_core_cards"

      paths.add "db/migrate_deck", with: "db/migrate"
      paths.add "db/migrate_deck_cards", with: "db/migrate"

      Cardio::Mod.each_path do |mod_path|
        app.config.autoload_paths += Dir["#{mod_path}/lib"]
        app.config.watchable_dirs["#{mod_path}/set"] = %i[rb haml]

        paths["config/initializers"] << "#{mod_path}/init/early"
        paths["late/initializers"] << "#{mod_path}/init/late"
        paths["config/locales"] << "#{mod_path}/locales"
      end

      paths["app/models"] = []
      paths["app/mailers"] = []
      paths["app/controllers"] = []
    end

    config.before_initialize do |app|
      paths = app.config.paths
      if app.config.load_strategy == :tmp_files
        %w[set set_pattern].each do |dir|
          if ENV["REPO_TMPSETS"]
            paths.add "tmp/#{dir}", with: "#{Cardio.gem_root}/tmpsets/#{dir}"
          else
            paths.add "tmp/#{dir}"
          end
        end
      end
    end
  end
end
