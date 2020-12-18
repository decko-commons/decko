# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # AbstractFormat manages the basic format API, including API to define a {#view}.
      # Whenever you create a format block in a set module in a {Cardio::Mod mod}, you
      # create a format module that is extended with AbstractFormat.
      module AbstractFormat
        include Set::Basket
        include ViewOpts
        include ViewDefinition
        include HamlViews
        include Wrapper

        # _Views_ are the primary way that both sharks and monkeys interact with cards.
        # Sharks select views to use in _nests_.  Monkeys can define and tweak those
        # views. These docs will introduce the basics of view definition.
        #
        # ## Sample view definitions
        #
        # Here is a very simple view that just defines a label for the card(its name):
        #
        #     view :label do
        #       card.name
        #     end
        #
        # View definitions can take the following forms:
        #
        #     view :viewname[, option_hash][, &block]          # standard
        #     view :viewname, alias_to_viewname[, option_hash] # aliasing
        #
        #
        # ## View definition options
        #
        # * __:alias_to__ [Symbol] name of view to which this view should be aliased. View
        #   must already be defined in self or specified mod.
        #
        # * __:async__ render view asynchronously by first rendering a card placeholder
        #   and then completing a request. Only applies to HtmlFormat
        #
        # * __:cache__ directs how to handle caching for this view. Supported values:
        #     * *:standard* - (default)
        #     * *:always* - cache even when rendered within another cached view
        #     * *:never* - don't ever cache this view. Frequently used to prevent caching
        #       problems
        #
        #   You should certainly {Card::View::Cache learn more about caching} if you want
        #   to develop mods that are safe in a caching environment.
        #
        # * __:compact__ [True/False]. Is view acceptable for rendering inside `compact`
        #   view?  Default is false.
        #
        # * __:denial__ [Symbol]. View to render if permission is denied. Value can be
        #   any viewname. Default is `:denial`. `:blank` is a common alternative.
        #
        # * __:perms__ restricts view permissions. Supported values:
        #     * *:create*, *:read* (default), *:update*, *:delete* - only users with the
        #       given permission for the card viewed.
        #     * *:none* - no permission check; anyone can view
        #     * a *Proc* object.  Eg `perms: ->(_fmt) { Auth.needs_setup? }`
        #
        # * __:template__ [Symbol] view is defined in a template. Currently `:haml` is
        #   the only supported value.  See {HamlViews}
        #
        # * __:unknown__ [True/False, Symbol]. Configures handling of "unknown" cards.
        #   (See {Set::All::States card states}). Supported values:
        #     * *true* render view even if card is unknown
        #     * *false* default unknown handling (depends on context, create permissions,
        #       etc)
        #     * a *Symbol*: name of view to render
        #
        # * __:wrap__ wrap view dynamically. Value is Symbol for wrapper or Hash with
        #   wrappers and wrapper options. See {Wrapper}
        #
        def view viewname, *args, &block
          def_opts = process_view_opts viewname, args
          define_view_method viewname, def_opts, &block
        end

        # simple placeholder for views designed to be overridden elsewhere
        def view_for_override viewname
          # LOCALIZE
          view viewname do
            "override '#{viewname}' view"
          end
        end

        # define code to be executed before a view is rendered
        def before view, &block
          define_method "_before_#{view}", &block
        end

        # Defines a setting method that can be used in all formats. Example:
        #
        #     format do
        #       setting :cols
        #       cols 5, 7
        #
        #       view :some_view do
        #         cols  # => [5, 7]
        #       end
        #     end
        #
        # @param name [Symbol] name of setting. should be available method name
        def setting name
          Card::Set::Format::AbstractFormat.send :define_method, name do |*args|
            define_method name do
              args
            end
          end
        end

        # file location where set mod is stored
        def source_location
          set_module.source_location
        end

        # @return constant for set module (without format)
        def set_module
          Card.const_get name.split("::")[0..-2].join("::")
        end
      end
    end
  end
end
