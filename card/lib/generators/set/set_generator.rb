# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # generate set module files
    class SetGenerator < ModBase
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string, banner: "MOD"
      argument :set_pattern, required: true
      argument :anchors, required: true, type: :array, banner: "[ANCHOR1] [ANCHOR2]"

      class_option "spec-only", type: :boolean,
                                default: false, group: :runtime,
                                desc: "create only spec file"

      def create_files
        template "set_template.erb", set_path unless options["spec-only"]
        template "set_spec_template.erb", set_path("spec")
      end

      private

      def set_path modifier=nil
        suffix = modifier ? "_#{modifier}" : nil
        filename = "#{anchors.last}#{suffix}.rb"
        dirs = anchors[0..-2]
        path_parts = [mod_path, modifier, "set", set_pattern, dirs, filename]
        File.join(*path_parts.compact)
      end

      def module_class_string
        "Card::Set::#{set_pattern.camelize}::#{anchors.map(&:camelize).join '::'}"
      end
    end
  end
end
