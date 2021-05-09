# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class ModGenerator < NamedBase
      class_option "core",
                   type: :boolean, aliases: "-c",
                   default: false, group: :runtime,
                   desc: "create mod Card gem"

      def create_mod_tree
        create_empty_tree mod_path => { lib: %i[javascript stylesheets],
                                        public: [:assets],
                                        set: [] }
      end

      private

      def create_empty_tree structure
        return unless structure.present?

        if structure.is_a?(Hash)
          structure.each_pair do |k, v|
            empty_directory k.to_s
            inside k.to_s do
              create_empty_tree v
            end
          end
        else
          Array.wrap(structure).each do |v|
            empty_directory v.to_s
          end
        end
      end
    end
  end
end
