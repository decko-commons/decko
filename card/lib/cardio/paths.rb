module Cardio
  # railtie helper. needs refactoring.
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
      add_gem_environment_path
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
