module Cardio
  module Mod
    # Dirs objects are used to manage the load paths for card mods.
    # Mods can be loaded as gems and by using directories with mod subdirectories.
    #
    # 1. Gemfile
    # A mod gem needs a metadata attribute with { "card-mod" => "the_mod_name" }
    # or the name has to start with "card-mod-".
    # Then you can just add it to your Gemfile. Otherwise it won't be recognized as mod.
    #
    # 2. mod directory
    # Give a path to a directory with mods. The mods will be loaded in alphabetical order.
    # To change the load order you can add number prefixes to the mod names
    # (like "01_this_first") or add a Modfile.
    # In the Modfile you list all the mods you want to be loaded from that directory
    # in load order with a preceding "mod" command (similar to a Gemfile).
    # The mods are expected in subdirectories with the mod names.
    #
    # Mods in Modfiles are always loaded before mods in the Gemfile.
    # If you have to change the order add gem mods to your Modfile using the
    # mod_gem command. You can omit the 'card-mod' prefix.
    #
    # Example for a mod directory:
    #   # my_mod/Modfile
    #   mod "twitter"
    #   gem_mod "logger"
    #   mod "cache"
    #
    #   # directory structure
    #   my_mods/
    #     Modfile
    #     cache/
    #       set/
    #         all/
    #           my_cache.rb
    #     twitter/
    #       set/
    #         type/
    #           basic.rb
    #       set_pattern/
    #         my_pattern.rb
    #
    # Dir checks always for gems. You can initialize an Dirs object with an additional
    # array of paths to card mod directories.
    class Dirs < Array
      attr_reader :mods

      # @param mod_paths [String, Array<String>] paths to directories that contain mods
      def initialize mod_paths=[]
        @mods = []
        @mods_by_name = {}
        @loaded_gem_mods = ::Set.new
        mod_paths = Array(mod_paths)
        mod_paths.each do |mp|
          @current_path = mp
          load_from_modfile || load_from_dir
        end
        load_from_gemfile
        super()
        @mods.each do |mod|
          self << mod.path
        end
      end

      def add_gem_mod mod_name, mod_path
        return if @loaded_gem_mods.include?(mod_name)

        @loaded_gem_mods << mod_name
        add_mod mod_name, mod_path
      end

      # Add a mod to mod load paths
      def add_mod mod_name, path=nil
        if @mods_by_name.key? Card::Mod.normalize_name(mod_name)
          raise Card::Error,
                "name conflict: mod with name \"#{mod_name}\" already loaded"
        end

        path ||= File.join @current_path, mod_name
        mod = Card::Mod.new(mod_name, path, @mods.size)
        @mods << mod
        @mods_by_name[mod.name] = mod
      end

      def delete_mod mod_name
        name = Card::Mod.normalize_name(mod_name)
        mod = @mods_by_name[name]
        @mods.delete mod
        @mods_by_name.delete name
      end

      # @param mod_name [String] the name of a mod
      # @return the path to mod `mod_name`
      def path mod_name
        fetch_mod(mod_name)&.path
      end

      def fetch_mod mod_name
        @mods_by_name[Card::Mod.normalize_name(mod_name)]
      end

      # Iterate over each mod directory
      # @param type [Symbol] the type of modification like set, set_pattern, or format.
      #   It is attached as subdirectory.
      def each type=nil
        super() do |path|
          dirname = dirname path, type
          yield dirname if Dir.exist? dirname
        end
      end

      def dirname path, type
        type ? File.join(path, type.to_s) : path
      end

      def each_tmp type
        @mods.each do |mod|
          path = mod.tmp_dir type
          yield path if Dir.exist? path
        end
      end

      def each_with_tmp type=nil
        @mods.each do |mod|
          dirname = dirname mod.path, type
          yield dirname, mod.tmp_dir(type) if Dir.exist? dirname
        end
      end

      def each_public_assets_path
        @mods.each do |mod|
          path = mod.public_assets_path
          next unless Dir.exist? path

          yield mod, path
        end
      end

      def each_assets_path
        @mods.each do |mod|
          path = mod.assets_path
          next unless Dir.exist? path

          yield mod.name, path
        end
      end

      private

      def load_from_modfile
        modfile_path = File.join @current_path, "Modfile"
        return unless File.exist? modfile_path

        loader = ModfileLoader.new self
        loader.load modfile_path
        true
      end

      def load_from_dir
        Dir.entries(@current_path).sort.each do |filename|
          add_mod filename unless filename.match?(/^\./)
        end
      end

      def load_from_gemfile
        Cardio::Mod.gem_specs.each do |mod_name, mod_spec|
          add_gem_mod mod_name, mod_spec.full_gem_path
        end
      end
    end
  end
end
