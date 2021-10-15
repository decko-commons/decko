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
    config.google_analytics_tracker_key = nil

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
    config.load_strategy = (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)

    # TODO: support mod-specific railties

    config.before_configuration do |app|
      card_root = Cardio.gem_root

      app.config.tap do |c|
        c.autoloader = :zeitwerk
        c.autoload_paths += Dir["#{card_root}/lib"]

        c.paths.tap do |p|
          p["config/environments"].unshift "#{card_root}/config/environments"
          p["config/initializers"] << "#{card_root}/config/initializers"
          p.add "late/initializers", glob: "**/*.rb"

          p["lib/tasks"] << "#{card_root}/lib/tasks"

          p.add "mod", with: "#{card_root}/mod"
          p["mod"] << "mod"
          p.add "files"

          p.add "lib/graph_q_l/types/query.rb"

          p.add "db", with: "#{card_root}/db"
          p.add "db/seeds.rb", with: "#{card_root}/db/seeds.rb"
          p.add "db/migrate", with: "#{card_root}/db/migrate"
          p.add "db/migrate_core_cards", with: "#{card_root}/db/migrate_core_cards"

          p.add "db/migrate_deck", with: "db/migrate"
          p.add "db/migrate_deck_cards", with: "db/migrate_cards"

          Cardio::Mod.each_path do |mod_path|
            c.autoload_paths += Dir["#{mod_path}/lib"]
            c.watchable_dirs["#{mod_path}/set"] = %i[rb haml]

            p["lib/graph_q_l/types/query.rb"] <<
              "#{mod_path}/lib/graph_q_l/types/query.rb"
            p["config/initializers"] << "#{mod_path}/init/early"
            p["late/initializers"] << "#{mod_path}/init/late"
            p["config/locales"] << "#{mod_path}/locales"
            p["lib/tasks"] << "#{mod_path}/lib/tasks"
          end

          p["app/models"] = []
          p["app/mailers"] = []
          p["app/controllers"] = []
        end
      end
    end

    config.before_initialize do |app|
      app.config.tap do |c|
        if c.load_strategy == :tmp_files
          %w[set set_pattern].each do |dir|
            if ENV["REPO_TMPSETS"]
              c.paths.add "tmp/#{dir}", with: "#{Cardio.gem_root}/tmpsets/#{dir}"
            else
              c.paths.add "tmp/#{dir}"
            end
          end
        end
      end
    end
  end
end
