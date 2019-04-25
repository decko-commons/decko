# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # All Format modules are extended with AbstractFormat in order to support
      # the basic format API, including `view` definitions.
      module AbstractFormat
        # _Views_ are the primary way that both sharks interact with cards. These docs will introduce the basics of view definition
        #
        # Here is a very simple view that just defines a label for the card – its name:
        #
        #     view :label do
        #       card.name
        #     end
        #
        # If a format is not specified, the view is defined on the base format class,
        # Card::Format. The following two definitions are equivalent to the definition above:
        #
        #     format do
        #       view(:label) { card.name }
        #     end
        #
        #     format(:base) { view(:label) { card.name } }
        #
        # But suppose you would like this view to appear differently in different output
        # formats. For example, you'd like this label to have a tag with a class attribute HTML
        # so that you can style it with CSS.
        #
        #     format :html do
        #       view :label do
        #         div(class: "my-label") { card.name }
        #       end
        #     end
        #
        # Note that in place of card.name, you could also use `super`, because this view is
        # translated into a method on Card::Format::HtmlFormat, which inherits from
        # Card::Format.
        #
        # ## Common arguments for view definitions
        #
        # * :perms - restricts view permissions. Value can be :create, :read, :update, :delete,
        #            or a Proc.
        # * :tags - tag view as needed.
        #
        # The most common tag is "unknown_ok," which indicates that a view can be rendered even
        # if the card is "unknown" (not real or virtual).
        #
        # ## Rendering views
        #
        # To render our label view, you can use either of these:
        #
        #     render :label
        #     render_label
        #





        include Set::Basket
        include ViewOpts
        include ViewDefinition
        include HamlViews
        include Wrapper

        def view view, *args, &block
          def_opts = process_view_opts view, args
          define_view_method view, def_opts, &block
        end

        def view_for_override viewname
          # LOCALIZE
          view viewname do
            "override '#{viewname}' view"
          end
        end

        def before view, &block
          define_method "_before_#{view}", &block
        end

        # Defines a setting method that can be used in all formats
        # Example:
        #   format do
        #     setting :cols
        #     cols 5, 7
        #
        #     view :some_view do
        #       cols  # => [5, 7]
        #     end
        #   end
        def setting name
          Card::Set::Format::AbstractFormat.send :define_method, name do |*args|
            define_method name do
              args
            end
          end
        end

        def source_location
          set_module.source_location
        end

        # remove the format part of the module name
        def set_module
          Card.const_get name.split("::")[0..-2].join("::")
        end
      end
    end
  end
end
