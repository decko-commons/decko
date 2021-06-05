# -*- encoding : utf-8 -*-

require "rails/generators"
require "rails/generators/active_record"

module Cardio
  module Generators
    class NamedBase < ::Rails::Generators::NamedBase
      extend ClassMethods

      def mod_path
        @mod_path ||= begin
                        path_parts = ["mod", file_name]
                        path_parts.unshift Cardio.gem_root if options.core?
                        File.join(*path_parts)
                      end
      end
    end

    class MigrationBase < ::ActiveRecord::Generators::Base
      extend ClassMethods
    end
  end
end
