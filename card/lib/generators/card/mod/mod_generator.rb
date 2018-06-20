# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class ModGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      class_option "core",
                   type: :boolean, aliases: "-c",
                   default: false, group: :runtime,
                   desc: "create mod Card gem"

      def create_directories
        empty_directory mod_path
        inside mod_path do
          Dir.chdir(self.class.source_root) do
            Dir.glob("**/*").each do |path|
              empty_directory path
            end
          end
        end
      end
    end
  end
end
