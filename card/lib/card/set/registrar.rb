# -*- encoding : utf-8 -*-

class Card
  module Set
    # the set loading process has two main phases:
    #
    #  1. Definition: interpret each set file, creating/defining set and
    #     set_format modules
    #  2. Organization: have base classes include modules associated with the
    #     'all' set, and clean up the other modules
    module Registrar
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Definition Phase

      # each set file calls `extend Card::Set` when loaded
      def extended mod
        register_set mod
      end

      # make the set available for use
      def register_set set_module
        if set_module.all_set?
          # automatically included in Card class
          modules[:base] << set_module
        else
          set_type = set_module.abstract_set? ? :abstract : :nonbase
          register_set_of_type set_module, set_type
        end
      end

      #
      #  When a Card application loads, it uses set modules to autogenerate
      #  tmp files that add module names (Card::Set::PATTERN::ANCHOR) and
      #  extend the module with Card::Set.

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Organization Phase

      # 'base modules' are modules that are always included on the Card or
      # Format class
      # 'nonbase modules' are included dynamically on singleton_classes
      def process_base_modules
        base_modules = modules[:base]
        return unless base_modules.present?

        Card.add_set_modules base_modules
        process_base_format_modules modules[:base_format]
        base_modules.clear
      end

      def finalize_load
        # basket.freeze
        # basket.each_value(&:freeze)
        clean_empty_modules
      end

      private

      def clean_empty_modules
        clean_empty_module_from_hash modules[:nonbase]
        modules[:nonbase_format].each_value do |hash|
          clean_empty_module_from_hash hash
        end
      end

      def clean_empty_module_from_hash hash
        hash.each do |mod_name, modlist|
          modlist.delete_if { |x| x.instance_methods.empty? }
          hash.delete mod_name if modlist.empty?
        end
      end

      # makes sets ready for dynamic loading via #include_set_modules
      def register_set_of_type set_module, set_type
        list = modules[set_type][set_module.shortname] ||= []
        list << set_module unless list.member? set_module
      end

      def process_base_format_modules base_format_modules
        base_format_modules.each do |format_class, modules_list|
          format_class.add_set_modules modules_list
        end
        base_format_modules.clear
      end
    end
  end
end
