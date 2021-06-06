# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    class NamedBase < ::Rails::Generators::NamedBase
      extend ClassMethods

      def mod_path
        @mod_path = if (path = options["mod-path"])
                      File.expand_path path
                    else
                      File.join "mod", file_name
                    end
      end
    end
  end
end
