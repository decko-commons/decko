class Card

  def config
    Cardio.config
  end

  def paths
    Cardio.paths
  end

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
    # Example for a mod directory:
    #   # my_mod/Modfile
    #   mod "twitter"
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
        @paths = {}
        mod_paths = Array(mod_paths)
        mod_paths.each do |mp|
          @current_path = mp
          load_from_modfile || load_from_dir
        end
        load_from_gemfile
        super()
        @mods.each do |mod_name|
          self << @paths[mod_name]
        end
      end

      # Add a mod to mod load paths
      def add_path mod_name, path=nil
        if @mods.include? mod_name
          raise Error,
                "name conflict: mod with name \"#{mod_name}\" already loaded"
        end
        @mods << mod_name
        path ||= File.join @current_path, mod_name
        @paths[mod_name] = path
      end

      alias_method :mod, :add_path

      # @param mod_name [String] the name of a mod
      # @return the path to mod `mod_name`
      def path mod_name
        @paths[mod_name]
      end

      # Iterate over each mod directory
      # @param type [Symbol] the type of modification like set, set_pattern, or format.
      #   It is attached as subdirectory.
      def each type=nil
        super() do |path|
          dirname = type ? File.join(path, type.to_s) : path
          next unless Dir.exist? dirname
          yield dirname
        end
      end

      def each_tmp type
        @mods.each do |mod|
          path = tmp_dir mod, type
          next unless Dir.exist? path
          yield path
        end
      end

      def each_with_tmp type=nil
        @mods.each do |mod|
          dirname = type ? File.join(@paths[mod], type.to_s) : @paths[mod]
          next unless Dir.exist? dirname
          yield dirname, tmp_dir(mod, type)
        end
      end

      private

      def load_from_modfile
        modfile_path = File.join @current_path, "Modfile"
        return unless File.exist? modfile_path
        eval File.read(modfile_path), binding
      end

      def load_from_dir
        Dir.entries(@current_path).sort.each do |filename|
          next if filename =~ /^\./
          add_path filename
        end.compact
      end

      def load_from_gemfile
        Bundler.definition.specs.map do |s|
          mod_name =
            if s.name =~ /^decko-mod-(.+)$/
              $1
            else
              s.metadata["card-mod"]
            end
          next unless mod_name
          add_path $1, s.full_gem_path
        end.compact
      end

      def tmp_dir modname, type
        index = @mods.index modname
        File.join Card.paths["tmp/#{type}"].first,
                  "mod#{'%03d' % (index + 1)}-#{modname}"
      end
    end
  end
end
