module Cardio
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
      puts "add_initializers (config.root) #{config.root}"

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
