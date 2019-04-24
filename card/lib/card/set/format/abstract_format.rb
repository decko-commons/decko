# -*- encoding : utf-8 -*-

class Card
  module Set
    module Format
      # All Format modules are extended with this module in order to support
      # the basic format API, including view, layout, and basket definitions
      module AbstractFormat
        include Set::Basket
        include Set::Format::HamlViews
        include Set::Format::Wrapper

        VIEW_SETTINGS = %i[cache modal bridge wrap].freeze
        VIEW_DEFINITION_OPTS = %i[alias_to mod template async].freeze

        mattr_accessor :views
        self.views = Hash.new { |h, k| h[k] = {} }

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

        def view view, *args, &block
          def_opts = interpret_view_opts! view, args
          define_view_method view, def_opts, &block
        end

        def view_for_override viewname
          view viewname do
            "override '#{viewname}' view"
          end
        end

        def source_location
          set_module.source_location
        end

        # remove the format part of the module name
        def set_module
          Card.const_get name.split("::")[0..-2].join("::")
        end

        private

        def define_view_method view, def_opts, &block
          view_block = view_block view, def_opts, &block
          view_type = def_opts[:async] ? :async : :standard
          send "define_#{view_type}_view_method", view, &view_block
        end

        def define_standard_view_method view, &block
          views[self][view] = block
          define_method Card::Set::Format.view_method_name(view), &block
        end

        def define_async_view_method view, &block
          # This case makes only sense for HtmlFormat
          # but I don't see an easy way to override class methods for a specific
          # format. All formats are extended with this general module. So
          # a HtmlFormat.view method would be overridden by AbstractFormat.view
          # We need something like AbstractHtmlFormat for that.

          view_content = "#{view}_async_content"
          define_standard_view_method view_content, &block
          define_standard_view_method view do
            %(<card-view-placeholder data-url="#{path view: view_content}" />)
          end
        end

        def interpret_view_opts! view, args
          def_opts, opts = interpret_view_definition_opts args
          return def_opts unless opts.present?

          Card::Format.interpret_view_opts view, opts
          interpret_view_settings view, opts
          fail_on_invalid_opts! view, opts
          def_opts
        end

        def fail_on_invalid_opts! view, opts
          return unless opts.present?

          raise Card::Error::ServerError,
                "unknown view opts for #{view} view: #{opts}"
        end

        def interpret_view_definition_opts args
          def_opts = {}
          def_opts[:alias_to] = args.shift if args[0].is_a?(Symbol)
          opts = args.shift || {}
          VIEW_DEFINITION_OPTS.each do |k|
            def_opts[k] ||= opts.delete k
          end
          [def_opts, opts]
        end

        def interpret_view_settings view, opts
          VIEW_SETTINGS.each do |setting_name|
            define_view_setting_method view, setting_name, opts.delete(setting_name)
          end
        end

        def define_view_setting_method view, setting_name, setting_value
          return unless setting_value

          method_name = Card::Format.view_setting_method_name view, setting_name
          define_method(method_name) { setting_value }
        end

        def view_block view, def_opts, &block
          if (template = def_opts[:template])
            template_view_block view, template, &block
          elsif (alias_to = def_opts[:alias_to])
            alias_view_block view, alias_to, def_opts[:mod], &block
          else
            block
          end
        end

        def template_view_block view, template, &block
          return haml_view_block(view, &block) if template == :haml

          raise Card::Error::ServerError, "unknown view template: #{template}"
        end

        def alias_view_block view, alias_to, mod=nil
          mod ||= self
          if block_given?
            raise Card::Error::ServerError, "no blocks allowed in aliased views"
          end
          views[mod][alias_to] || begin
            raise "cannot find #{alias_to} view in #{mod}; " \
                  "failed to alias #{view} from #{self}"
          end
        end
      end
    end
  end
end
