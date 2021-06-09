# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    class ModGenerator < ModBase
      def create_mod
        inside mod_path do
          assets_dir
          set_dir
          spec_dir
          config_dir
          public_dir
        end
      end

      def root_files
        template "README.md.erb", "#{mod_path}/README.md"
      end

      private

      def assets_dir
        inside "assets" do
          empty_directory "javascript"
          empty_directory "stylesheets"
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
          empty_directory "initializers"
        end
      end

      def public_dir
        inside "public" do
          empty_directory "assets"
        end
      end
    end
  end
end
