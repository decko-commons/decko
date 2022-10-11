module Cardio
  class Mod
    # Methods used via "eval" in Modfiles
    module ModfileApi
      def mod *args
        @dirs.add_mod *args
      end

      def gem_mod name
        deps = Mod.dependencies name
        unknown_gem_mod!(name) if deps.blank?
        deps.each { |spec| @dirs.add_gem_mod spec.name, spec.full_gem_path }
      end

      # add all gem mods
      def gem_mods
        @dirs.add_from_gemfile
      end

      private

      def unknown_gem_mod! name
        raise Card::Error, %(Unknown gem "#{name}". Make sure it is in your Gemfile.)
      end
    end
  end
end
