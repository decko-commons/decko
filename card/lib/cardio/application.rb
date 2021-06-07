require "cardio/all"

Bundler.require :default, *Rails.groups

# TODO: Move these to modules that use them
require "htmlentities"
require "coderay"
require "kaminari"
require "bootstrap4-kaminari-views"
require "builder"

module Cardio
  # handles config and path defaults
  class Application < Rails::Application
    def self.card_environment_initializer
      initializer "card.load_environment_config",
                  before: :load_environment_config, group: :all do
        paths["card/config/environments"].existent.each do |environment|
          require environment
        end
      end
    end
    card_environment_initializer

    def config
      @config ||= super.tap do |config|
        simple_configs config
        coded_configs config
      end
    end

    private

    def simple_configs config
      config_from_yaml.each_pair do |setting, value|
        config.send "#{setting}=", *value
      end
    end

    # TODO: many of these defaults should be in mods!
    def config_from_yaml
      YAML.load_file File.expand_path("defaults.yml", __dir__)
    end

    def coded_configs config
      config.autoloader = :zeitwerk
      config.i18n.enforce_available_locales = true
      config.read_only = !ENV["DECKO_READ_ONLY"].nil?
      config.load_strategy = (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)
      config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]
      Paths.new(config).assign
      Cardio::Mod.each_path do |mod_path|
        config.autoload_paths += Dir["#{mod_path}/lib"]
        config.watchable_dirs["#{mod_path}/set"] = %i[rb haml]
      end
    end

    class Paths
      attr_reader :config, :paths

      def initialize config
        @config = config
        @paths = config.paths
      end

      def assign
        add_tmppaths
        add_path "mod"        # add card gem's mod path
        paths["mod"] << "mod" # add deck's mod path
        paths.add "files"

        add_db_paths
        add_initializer_paths
        add_mod_initializer_paths
        add_gem_environment_path

        paths["app/models"] = []
        paths["app/mailers"] = []
        paths["app/controllers"] = []
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
          { root: config.root }
        end
      end

      def add_db_paths
        add_path "db"
        add_path "db/migrate"
        add_path "db/migrate_core_cards"
        add_path "db/migrate_deck", root: config.root, with: "db/migrate"
        add_path "db/migrate_deck_cards", root: config.root, with: "db/migrate_cards"
        add_path "db/seeds.rb", with: "db/seeds.rb"
      end

      def add_initializer_paths
        add_path "config/initializers", glob: "**/*.rb"
        add_initializers config.root
        Cardio::Mod.each_path do |mod_path|
          add_initializers mod_path, false, "core_initializers"
        end
      end

      def add_mod_initializer_paths
        add_path "mod/config/initializers", glob: "**/*.rb"
        Cardio::Mod.each_path do |mod_path|
          add_initializers mod_path, true
        end
      end

      def add_initializers base_dir, mod=false, init_dir="initializers"
        Dir.glob("#{base_dir}/config/#{init_dir}").each do |initializers_dir|
          path_mark = mod ? "mod/config/initializers" : "config/initializers"
          paths[path_mark] << initializers_dir
        end
      end

      def add_gem_environment_path
        add_path "card/config/environments",
                 glob: "#{Rails.env}.rb",
                 with: "config/environments"
      end

      def add_path path, options={}
        root = options.delete(:root) || Cardio.gem_root
        options[:with] = File.join(root, (options[:with] || path))
        paths.add path, options
      end
    end
  end
end
