module Cardio
  module Mod
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
