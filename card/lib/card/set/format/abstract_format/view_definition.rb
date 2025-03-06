class Card
  module Set
    module Format
      module AbstractFormat
        # handles definition of view methods
        module ViewDefinition
          mattr_accessor :views
          self.views = Hash.new { |h, k| h[k] = {} }

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
end
