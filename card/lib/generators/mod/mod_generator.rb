# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # generate mod with standard directories
    class ModGenerator < ModBase
      def create_mod
        inside mod_path do
          assets_dir
          config_dir
          set_dir
          spec_dir
          empty_directory "public"
        end
      end

      def root_files
        template "README.md.erb", "#{mod_path}/README.md"
      end

      private

      def assets_dir
        inside "assets" do
          empty_directory "script"
          empty_directory "style"
        end
      end

      def set_dir
        inside "set" do
          %w[abstract all type type_plus_right right self].each do |pattern|
            empty_directory pattern
          end
        end
      end

      def spec_dir
        inside "spec" do
          set_dir
        end
      end

      def config_dir
        inside "config" do
          # empty_directory "before"
          empty_directory "early"
          empty_directory "late"
          empty_directory "locales"
        end
      end
    end
  end
end
