module Cardio
  # primary railtie for cards
  class Railtie < Rails::Railtie
    config.encoding = "utf-8"

    config.seed_mods = [:core]
    config.seed_type = :real
    config.extra_seed_tables = []

    # if you disable inline styles tinymce's formatting options stop working
    config.allow_inline_styles = true
    config.token_expiry = 2.days

    config.no_authentication = false

    config.max_char_count = 200
    config.max_depth = 20
    config.email_defaults = nil

    config.space_last_in_multispace = true

    config.view_cache = false

    config.request_logger = false
    config.performance_logger = false
    config.sql_comments = false

    config.deck_origin = nil

    config.rich_text_editor = :tinymce

    config.sharedcache = true
    config.prepopulate_cache = false
    config.asset_refresh = :cautious
    config.compress_assets = true

    config.allow_irreversible_admin_tasks = false
    config.raise_all_rendering_errors = false

    config.cache_set_module_list = false

    config.i18n.enforce_available_locales = true
    config.read_only = !ENV["DECKO_READ_ONLY"].nil?
    config.load_strategy = ENV["CARD_LOAD_STRATEGY"]&.to_sym || :eval

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

          p.add "mod"
          p.add "files"

          p.add "lib/graph_q_l/types/query.rb"
          p.add "mod-data"
          p.add "data/schema"
          p.add "data/transform"

          p.add "db", with: "#{card_root}/db"
          p.add "db/seeds.rb", with: "#{card_root}/db/seeds.rb"

          Cardio::Mod.dirs.each do |mod_path|
            c.autoload_paths += Dir["#{mod_path}/lib"]
            c.watchable_dirs["#{mod_path}/set"] = %i[rb haml]

            p["lib/graph_q_l/types/query.rb"] <<
              "#{mod_path}/lib/graph_q_l/types/query.rb"
            p["config/environments"] << "#{mod_path}/config/environments"
            p["config/initializers"] << "#{mod_path}/config/early"
            p["late/initializers"] << "#{mod_path}/config/late"
            p["lib/tasks"] << "#{mod_path}/lib/tasks"

            p["mod-data"] << "#{mod_path}/data"
            p["data/schema"] << "#{mod_path}/data/schema"
            p["data/transform"] << "#{mod_path}/data/transform"

            p["config/locales"] << "#{mod_path}/config/locales"
          end

          # Card doesn't use these rails patterns
          p["app/models"] = []
          p["app/mailers"] = []
          p["app/controllers"] = []
        end
      end
    end

    config.before_initialize do |app|
      app.config.tap do |c|
        if c.load_strategy == :tmp_files
          %w[set set_pattern].each { |dir| c.paths.add "tmp/#{dir}" }
        end
      end
    end

    def self.require_mod_gem mod_name
      require mod_name.name.to_s.tr("-", "/")
    rescue LoadError
    end

    Cardio::Mod.gem_specs.each_value { |mod_name| require_mod_gem mod_name }
  end
end
