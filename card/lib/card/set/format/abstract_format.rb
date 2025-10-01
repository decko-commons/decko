# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # AbstractFormat manages the DSL for defining {#view views}.
      #
      # Whenever you create a {Format format} block in a {Cardio::Set set module},
      # you create a format module that is extended with AbstractFormat.
      module AbstractFormat
        include ViewOpts
        include ViewDefinition
        include HamlViews
        include Wrapper

        delegate :basket, to: Set

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
        #     * *:default* - (default) do not independently cache this view. However, if
        #       this view is rendered by another view of the same card, and that view is
        #       cached, it's ok to cache it.
        #     * *:yes* - cache this view whenever it's safe to do so. Do NOT start
        #       a new caching when this view is rendered inside another view of the same
        #       card. And do NOT include
        #       nested cards in your cache. (Instead, stub them and process them
        #       separately)
        #     * *:always* - cache even when rendered within another cached view
        #     * *:deep* cache this view and include nested cards (but stub nested views
        #       that are set to "never")
        #     * *:never* - don't ever cache this view, even if it's rendered by another
        #       view of the same card. Frequently used to prevent caching problems, when
        #       dynamic context (eg params) can alter the view.
        #     * *:force* - deep cache everything, even views marked "never"
        #
        #   You should certainly {Card::View::Cache learn more about caching} if you want
        #   to develop mods that are safe in a caching environment.
        #
        # * __:expire__ handles cache expiration. (can only apply when cache setting is
        #     yes, always, or deep)
        #
        #     * *:hour* - expire when the hour next changes
        #     * *:day* - expire when the day next changes
        #     * *:week* - expire when the week next changes
        #     * *:month* - expire when the month next changes
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
        #     * a format method name.  Eg `perms: :is_my_view_ok?`
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
        def view(viewname, *args, &)
          def_opts = process_view_opts viewname, args
          define_view_method(viewname, def_opts, &)
        end

        # simple placeholder for views designed to be overridden elsewhere
        def view_for_override viewname
          # LOCALIZE
          view viewname do
            "override '#{viewname}' view"
          end
        end

        # define code to be executed before a view is rendered
        def before(view, &)
          define_method("_before_#{view}", &)
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
