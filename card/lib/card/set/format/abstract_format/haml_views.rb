class Card
  module Set
    module Format
      module AbstractFormat
        # Support haml templates in a Rails like way:
        # If the view option `template: :haml` is set then a haml template is expected
        # in a corresponding template path and renders it.
        #
        # @example
        #   # mod/core/set/type/basic.rb
        #   view :my_view, template: :haml  # uses mod/core/view/type/basic/my_view.haml
        #
        #   view :sample_view, template: :haml do
        #     @actor = "Mark Haml"
        #   end
        #
        #   # mod/core/set/type/basic/sample_view.haml
        #   Luke is played by
        #     = actor
        #
        #   > render :sample_view  # => "Luke is played by Mark Haml"
        module HamlViews
          include Card::Set::Format::HamlPaths

          private

          def haml_view_block view, &block
            path = haml_template_path view
            haml_template_proc ::File.read(path), path, &block
          end

          def haml_template_proc template, path, &block
            proc do
              with_template_path path do
                locals = haml_block_locals(&block)
                haml_to_html template, locals, nil, path: path
              end
            end
          end
        end
      end
    end
  end
end
