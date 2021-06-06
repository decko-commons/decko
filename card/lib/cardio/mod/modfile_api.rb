module Cardio
  module Mod
    module ModfileApi
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

      alias_method :mod, :add_mod

      def gem_mod name
        deps = Mod.dependencies name
        unknown_gem_mod!(name) if deps.blank?
        deps.each { |spec| add_gem_mod spec.name, spec.full_gem_path }
      end
    end
  end
end
