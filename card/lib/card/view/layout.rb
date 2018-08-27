class Card
  class View
      # method to render views with layouts
      module Layout
        MAX_LAYOUT_NESTING = 15

        def with_layouts _view, &block
          init_layout_stack block
          render_layouts
        end

        def init_layout_stack block
          return unless @layout_stack.nil?
          @layout_depth_count = 0
          @layout_stack = [block]
          @layout_stack += layout if layout.present?
          @layout_stack.compact!
        end

        def process_next_layout
          layout = @layout_stack.pop
          ::Card::Layout.render layout, @format
        end

        def check_layout_deepness
          if @layout_depth_count > MAX_LAYOUT_NESTING
            raise Card::Error, "layouts nested too deep"
          end
        end

        def wrap_with_layout layout, &block
          @layout_stack.push block
          @layout_stack.push layout
          #@inner_render.push block
          render_layouts
        end

        def render_layouts
          return unless layouts?
          check_layout_deepness
          @layout_depth_count += 1
          process_next_layout
        end

        def layouts?
          @layout_stack.present?
        end
      end
  end
end
