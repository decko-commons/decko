Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    initializer "cardio.load_defaults", before: :load_environment_config, group: :all do
      add_tmppaths
      add_path "mod"        # add card gem's mod path
      paths["mod"] << "mod" # add deck's mod path

      add_db_paths
      add_initializer_paths
      add_mod_initializer_paths
      default_autoload_paths

      default_configs.each_pair do |setting, value|
        config.send "#{setting}=", *value
      end
    end

    private

    # TODO: many of these defaults should be in mods!
    def default_configs
      defaults_from_yaml.merge(
        read_only: !ENV["DECKO_READ_ONLY"].nil?,
        load_strategy: (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)
      )
    end

    def defaults_from_yaml
      filename = File.expand_path "defaults.yml", __dir__
      YAML.load_file filename
    end

    def default_autoload_paths
      config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]

      # TODO: this should use each_mod_path, but it's not available when this is run
      # This means libs will not get autoloaded (and sets not watched) if the mod
      # dir location is overridden in config
      [Cardio.gem_root, config.root].each do |dir|
        autoload_and_watch "#{dir}/mod/*"
      end
      Cardio.gem_mod_specs.each_value do |spec|
        autoload_and_watch spec.full_gem_path
      end

      # the watchable_dirs are processed in the
      # set_clear_dependencies_hook hook in the railties gem in finisher.rb

      # TODO: move this to the right place in decko
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
    end

    def autoload_and_watch mod_path
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
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
  end
end
