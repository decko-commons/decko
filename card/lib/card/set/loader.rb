# -*- encoding : utf-8 -*-

class Card
  module Set
    # the set loading process has two main phases:

    #  1. Definition: interpret each set file, creating/defining set and
    #     set_format modules
    #  2. Organization: have base classes include modules associated with the
    #     'all' set, and clean up the other modules
    module Loader
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
          # made ready for dynamic loading via #include_set_modules
          modules[set_type][set_module.shortname] ||= []
          modules[set_type][set_module.shortname] << set_module
        end
      end

      #
      #  When a Card application loads, it uses set modules to autogenerate
      #  tmp files that add module names (Card::Set::PATTERN::ANCHOR) and
      #  extend the module with Card::Set.

      #

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Organization Phase

      # 'base modules' are modules that are permanently included on the Card or
      # Format class
      # 'nonbase modules' are included dynamically on singleton_classes
      def process_base_modules
        return unless modules[:base].present?
        Card.add_set_modules modules[:base]
        modules[:base_format].each do |format_class, modules_list|
          format_class.add_set_modules modules_list
        end
        modules[:base].clear
        modules[:base_format].clear
      end

      def clean_empty_modules
        clean_empty_module_from_hash modules[:nonbase]
        modules[:nonbase_format].values.each do |hash|
          clean_empty_module_from_hash hash
        end
      end

      def clean_empty_module_from_hash hash
        hash.each do |mod_name, modlist|
          modlist.delete_if { |x| x.instance_methods.empty? }
          hash.delete mod_name if modlist.empty?
        end
      end
    end
  end
end
