# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # All Format modules are extended with this module in order to support
      # the basic format API, including view, layout, and basket definitions
      module AbstractFormat
        include Set::Basket
        include Set::Format::ViewOpts
        include Set::Format::ViewDefinition
        include Set::Format::HamlViews
        include Set::Format::Wrapper

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
