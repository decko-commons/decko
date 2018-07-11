# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # All Format modules are extended with this module in order to support
      # the basic format API (ok, view definitions.  It's just view
      # definitions.)
      # No longer just view definitions. Also basket definitions now.
      module AbstractFormat
        include Set::Basket
        include Set::Format::HamlViews

        mattr_accessor :views
        self.views = Hash.new { |h, k| h[k] = {} }

        def before view, &block
          define_method "_before_#{view}", &block
        end

        def view view, *args, &block
          # view = view.to_viewname.key.to_sym
          interpret_view_opts view, args[0] if block_given?
          view_method_block = view_block(view, args, &block)
          if async_view? args
            # This case makes only sense for HtmlFormat
            # but I don't see an easy way to override class methods for a specific
            # format. All formats are extended with this general module. So
            # a HtmlFormat.view method would be overridden by AbstractFormat.view
            # We need something like AbstractHtmlFormat for that.
            define_async_view_method view, &view_method_block
          else
            define_standard_view_method view, &view_method_block
          end
        end

        def view_for_override viewname
          view viewname do
            "override '#{viewname}' view"
          end
        end

        def define_standard_view_method view, &block
          views[self][view] = block
          define_method "_view_#{view}", &block
        end

        def define_async_view_method view, &block
          view_content = "#{view}_async_content"
          define_standard_view_method view_content, &block
          define_standard_view_method view do
            %(<card-view-placeholder data-url="#{path view: view_content}" />)
          end
        end

        def interpret_view_opts view, opts
          return unless opts.present?
          Card::Format.interpret_view_opts view, opts
          VIEW_SETTINGS.each do |setting_name|
            define_view_setting_method view, setting_name, opts.delete(setting_name)
          end
        end

        def define_view_setting_method view, setting_name, setting_value
          return unless setting_value
          method_name = Card::Format.view_setting_method_name view, setting_name
          define_method(method_name) { setting_value}
        end

        def view_block view, args, &block
          return haml_view_block(view, wrap_with_slot?(args), &block) if haml_view?(args)
          block_given? ? block : lookup_alias_block(view, args)
        end

        def haml_view? args
          args.first.is_a?(Hash) && args.first[:template] == :haml
        end

        def wrap_with_slot? args
          args.first.is_a?(Hash) && args.first[:slot]
        end

        def async_view? args
          args.first.is_a?(Hash) && args.first[:async]
        end

        def lookup_alias_block view, args
          opts = args[0].is_a?(Hash) ? args.shift : { view: args.shift }
          opts[:mod] ||= self
          opts[:view] ||= view
          views[opts[:mod]][opts[:view]] || begin
            raise "cannot find #{opts[:view]} view in #{opts[:mod]}; " \
                  "failed to alias #{view} in #{self}"
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
