# -*- encoding : utf-8 -*-

class Card
  module Set
    # Card::Set::Format is responsible for handling `format` blocks within the set module
    # DSL, which is used in {Cardio::Mod Set module} files found in {Cardio::Mod mods'}
    # set directories. Monkeys use the DSL to define views that apply to specific sets of
    # cards in specific formats. The views can then be
    # used by Monkeys in code and by Sharks via the UI.
    #
    # For example, imagine you have a set module file in `mod/mymod/type/my_type.rb`.
    # There you can define a view like this:
    #
    #     format :html do
    #       view :hello do
    #         greeting
    #       end
    #     end
    #
    # {AbstractFormat#view Learn more about defining views}
    #
    # This view will now be available to MyType cards in HTML -- but not in other formats.
    # Similarly, you can define other methods in format blocks:
    #
    #     format :html do
    #       def greeting
    #         :rocks
    #       end
    #     end
    #
    # The magic that happens here is that the method #greeting is now applicable (and
    # available) _only_ to the cards in the {Card::Set set} specified by the mod, and
    # only when rendering a view of the card in the HTML format. {Card::Format Learn
    # more about formats}.
    #
    # So if, for example, I had a card "MyCard" with the type "MyType", the following
    # should use the method above:
    #
    # ````
    # "MyCard".card.format(:html).greeting
    # ````
    #
    # ...but if the card had a different type, or if I tried to use the method in, say,
    # the JSON format, this #beethoven method wouldn't be available.
    #
    # Under the hood, the DSL creates a ruby module that looks something like
    # `Card::Set::Type::MyType::HtmlFormat`. This module will then be dynamically included
    # in HTML format objects for MyCard.
    #
    # As monkeys, we don't usually think about all that much, because we work in
    # the set module space, which lets us focus on the card patterns.
    #
    # Speaking of which, there are a few key patterns to be aware of:
    #
    # 1. Just as in {Card::Set sets}, format methods for narrower sets will override
    #    format methods for more general sets.  So if a #greeting method is defined
    #    for all cards and again for a specific card type, then the type method will
    #    override the all method when both apply.
    # 2. Similarly, specific formats inherit from more general formats, and all formats
    #    inherit from the base format. If a format is not specified, the format block
    #    will define methods on the base format class.
    #
    #         format do
    #           def farewell
    #             "goodbye"
    #           end
    #         end
    #
    # 3. It is possible to use super to refer to overridden methods.  For example
    #
    #         format :html do
    #           def goodbye
    #             "<em>#{super}</em>"
    #           end
    #         end
    #
    #     Note: Set precedence has a higher priority than Format precedence.
    #
    # 4. Some very powerful API calls (including {AbstractFormat#view view} and
    # {AbstractFormat#before before}) are defined in {AbstractFormat}. These methods are
    # always available in format blocks.
    #
    # 5. {#view} and {#before}, however, can ALSO both be called outside of a format
    # block. They will be defined on the base format.
    #
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
          register_all_set_format format_class, mod
        else
          register_standard_set_format format_class, mod
        end
      end

      # make mod ready to include in base (non-set-specific) format classes
      def register_all_set_format format_class, mod
        add_to_array_val Set.modules[:base_format], format_class, mod
      end

      def register_standard_set_format format_class, mod
        # ready to include dynamically in set members' format singletons
        format_hash = Set.modules[set_format_type_key][format_class] ||= {}
        add_to_array_val format_hash, shortname, mod
      end

      def add_to_array_val hash, key, val
        hash[key] ||= []
        hash[key] << val
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
