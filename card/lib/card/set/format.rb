# -*- encoding : utf-8 -*-

class Card
  module Set
    #  Whenever a Format object is instantiated for a card, it
    #  includes all views associated with BOTH (a) sets of which the card is a
    #  member and (b) the current format or its ancestors.  More on defining
    #  views below.
    #
    # View definitions
    #
    #   When you declare:
    #     view :view_name do
    #       #...your code here
    #     end
    #
    #   Methods are defined on the format
    #
    #   The external api with checks:
    #     render(:viewname, args)
    #
    #  TODO:
    #  introduce view settings
    #    cache
    #    perms
    #    unknown: true
    #    bridge
    module Format
      require_dependency "card/set/format/haml_views"
      require_dependency "card/set/format/abstract_format"

      def format *format_names, &block
        format_names.compact!
        if format_names.empty?
          format_names = [:base]
        elsif format_names.first == :all
          format_names =
            Card::Format.registered.reject { |f| Card::Format.aliases[f] }
        end
        format_names.each do |f|
          define_on_format f, &block
        end
      end

      def view *args, &block
        format { view(*args, &block) }
      end

      def view_for_override *args, &block
        format { view_for_override(*args, &block) }
      end

      def before view, &block
        format { before view, &block }
      end

      def define_on_format format_name=:base, &block
        # format class name, eg. HtmlFormat
        klass = Card::Format.format_class_name format_name

        # called on current set module, eg Card::Set::Type::Pointer
        mod = const_get_or_set klass do
          # yielding set format module, eg Card::Set::Type::Pointer::HtmlFormat
          m = Module.new
          register_set_format Card::Format.class_from_name(klass), m
          m.extend Card::Set::AbstractFormat
          m
        end
        mod.class_eval(&block)
      end

      def register_set_format format_class, mod
        if all_set?
          all_set_format_mod! format_class, mod
        else
          format_type = abstract_set? ? :abstract_format : :nonbase_format
          # ready to include dynamically in set members' format singletons
          format_hash = modules[format_type][format_class] ||= {}
          format_hash[shortname] ||= []
          format_hash[shortname] << mod
        end
      end

      # make mod ready to include in base (non-set-specific) format classes
      def all_set_format_mod! format_class, mod
        modules[:base_format][format_class] ||= []
        modules[:base_format][format_class] << mod
      end

      class << self
        def layout_method_name layout
          "_layout_#{layout.to_name.key}"
        end

        def wrapper_method_name wrapper
          "_wrapper_#{wrapper}"
        end

        def view_method_name view
          "_view_#{view}"
        end
      end
    end
  end
end
