# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # base class for mod-related generators
    class ModBase < ::Rails::Generators::NamedBase
      extend ClassMethods

      class_option "mod-path", aliases: "-m", group: :runtime, desc: "full path for mod"

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
