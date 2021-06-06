module Cardio
  module Mod
    # Loads the mod of a Modfile into a Mod::Dirs object
    class ModfileLoader
      include ModfileApi

      def initialize dirs
        @dirs = dirs
      end

      def load modfile_path
        eval File.read(modfile_path), binding
      end
    end
  end
end
