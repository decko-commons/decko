# -*- encoding : utf-8 -*-

class Card
  module Set
    # This document explains how to use format blocks within {Cardio::Mod mods}. To make
    # use of it, you will need to understand both {Cardio::Mod mods} and {Card::Set sets}.
    #
    # Within a card mod, you can define format blocks like the following:
    #
    #     format :html do
    #       def beethoven
    #         :rocks
    #       end
    #     end
    #
    # The magic that happens here is that the method #beethoven is now applicable (and
    # available) _only_ to the cards in the set specified by the mod, and only when
    # the card is rendering a view in the HTML format.
    #
    # If you care, you can certainly learn about how all this works. How the set module
    # creates a module that looks something like `Card::Set::Type::MyType::HtmlFormat`.
    # How the format object for a given card in the set includes this module dynamically
    # when it's initialized. And so on...
    #
    # But as monkeys, we don't usually think about all that much, because we work in
    # the set module space, which lets us focus on the card patterns.
    #
    # Speaking of which, there are a few key patterns to be aware of:
    #
    # 1. Just as in {Card::Set sets}, format methods for narrower sets will override
    #    format methods for more general sets.  So if a #beethoven method is defined
    #    for all cards and again for a specific card type, then the type method will
    #    override the all method when both apply.
    # 2. Similarly, specific formats inherit from more general formats, and all formats
    #    inherit from the base format. If a format is not specified, the format block
    #    will define methods on the base format class.
    #
    #         format do
    #           def haydn
    #             :sucks
    #           end
    #         end
    #
    # 3. It is possible to use super to refer to overridden methods.  For example
    #
    #         format :html do
    #           def haydn
    #             "<em>#{super}</em>"
    #           end
    #         end
    #
    #     Note: Set precedence has a higher priority than Format precedence.
    #
    # 4. {#view} and {#before} can both be called outside of a format block. They will
    #   be defined on the base format.
    #
    # 5. Some very powerful API calls (including {AbstractFormat#view view} and
    # {AbstractFormat#before before}) are defined in {AbstractFormat}. These methods are
    # always available in format blocks.
    module Format
      require "card/set/format/haml_paths"
      require "card/set/format/abstract_format"

      # define format behavior within a set module
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

      # shortcut for {AbstractFormat#view} for when #view is called outside of a format
      # block
      def view *args, &block
        format { view(*args, &block) }
      end

      # shortcut for {AbstractFormat#before} for when #before is called outside of a
      # format block
      def before view, &block
        format { before view, &block }
      end

      private

      def define_on_format format_name=:base, &block
        # format class name, eg. HtmlFormat
        klass = Card::Format.format_class_name format_name

        # called on current set module, eg Card::Set::Type::Pointer
        mod = const_get_or_set klass do
          # yielding set format module, eg Card::Set::Type::Pointer::HtmlFormat
          m = Module.new
          register_set_format Card::Format.class_from_name(klass), m
          m.extend Card::Set::Format::AbstractFormat
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
        # name of method for layout
        # used by wrapper
        def layout_method_name layout
          "_layout_#{layout.to_name.key}"
        end

        # name of method for wrapper
        # used by wrapped views
        def wrapper_method_name wrapper
          "_wrapper_#{wrapper}"
        end

        # name of method for view
        # used by #render
        def view_method_name view
          "_view_#{view}"
        end

        # name of method for setting for a given view.
        # used by #view_setting
        def view_setting_method_name view, setting_name
          "_view_#{view}__#{setting_name}"
        end
      end
    end
  end
end
