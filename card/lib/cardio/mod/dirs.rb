require "cardio/mod/modfile_loader"

module Cardio
  class Mod
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
        add_core_mods
        add_gem_mods
        Array(mod_paths).each do |mp|
          @current_path = mp
          add_from_modfile || add_from_dir
        end
        super()
        @mods.each { |mod| self << mod.path }
      end

      # Add a mod to mod load paths
      def add_mod mod_name, path: nil, group: nil, spec: nil
        if @mods_by_name.key? Mod.normalize_name(mod_name)
          raise StandardError,
                "name conflict: mod with name \"#{mod_name}\" already loaded"
        end

        path ||= File.join @current_path, mod_name
        group ||= @current_group

        mod = Mod.new mod_name, path, group: group, index: @mods.size, spec: spec
        @mods << mod
        @mods_by_name[mod.name] = mod
      end

      def delete_mod mod_name
        name = Mod.normalize_name mod_name
        mod = @mods_by_name[name]
        @mods.delete mod
        @mods_by_name.delete name
      end

      # @param mod_name [String] the name of a mod
      # @return the path to mod `mod_name`
      def path mod_name
        fetch_mod(mod_name)&.path
      end

      def subpaths *subdirs
        @mods.each_with_object({}) do |mod, hash|
          path = mod.subpath(*subdirs)
          hash[mod.name] = path if path
        end
      end

      def fetch_mod mod_name
        @mods_by_name[Mod.normalize_name(mod_name)]
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

      def each_subpath *subdirs
        subpaths(*subdirs).each do |mod_name, subpath|
          yield mod_name, subpath
        end
      end

      private

      def add_gem_mods
        Cardio::Mod.gem_specs.each do |mod_name, spec|
          add_gem_mod mod_name, spec
        end
      end

      def add_gem_mod mod_name, spec
        return if @loaded_gem_mods.include?(mod_name)

        @loaded_gem_mods << mod_name
        group = spec.metadata["card-mod-group"] || "gem"
        add_mod mod_name, path: spec.full_gem_path, group: group, spec: spec
      end

      def add_core_mods
        @current_path = File.join Cardio.gem_root, "mod"
        @current_group = "gem-card"
        add_from_dir
        @current_group = nil
      end

      def add_from_modfile
        modfile_path = File.join @current_path, "Modfile"
        return unless File.exist? modfile_path

        loader = ModfileLoader.new self
        loader.load modfile_path
        true
      end

      def add_from_dir
        Dir.entries(@current_path).sort.each do |filename|
          add_mod filename unless filename.match?(/^\./)
        end
      end
    end
  end
end
