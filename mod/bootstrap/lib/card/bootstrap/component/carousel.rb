class Card
  class Bootstrap
    class Component
      class Carousel < Component
        def render_content
          carousel(*@args, &@build_block)
        end

        def carousel id, active_index, &block
          @id = id
          @active_item_index = active_index
          @items = []
          instance_exec(&block)

          @html.div class: "carousel slide", id: id, "data-bs-ride" => "true" do
            indicators
            items
            control_prev
            control_next
          end
        end

        def item content=nil, &block
          @items << (content || block)
        end

        def items
          @html.div class: "carousel-inner" do
            @items.each_with_index do |item, index|
              carousel_item item, carousel_item_opts(index)
            end
          end
        end

        def carousel_item_opts index
          { class: "carousel-item" }.tap do |opts|
            add_class opts, "active" if index == @active_item_index
          end
        end

        def carousel_item item, html_opts
          @html.div html_opts do
            item = item.call if item.respond_to?(:call)
            @html << item if item.is_a?(String)
          end
        end

        def control_prev
          control_button :prev, "Previous"
        end

        def control_next
          control_button :next, "Next"
        end

        def control_button direction, description
          @html.button class: "carousel-control-#{direction}",
                       "data-bs-target": "##{@id}", type: "button" do
            @html.span class: "carousel-control-#{direction}-icon",
                       "aria-hidden": "true" do
              ""
            end
            @html.span description, class: "visually-hidden"
          end
        end

        def indicators
          @html.div class: "carousel-indicators" do
            @items.size.times { |i| indicator i }
          end
        end

        def indicator index
          html_opts = { "data-bs-slide-to": index, "data-bs-target": "##{@id}",
                        type: "button", "aria-label": "Slide #{index + 1}" }
          add_class html_opts, "active" if index == @active_item_index
          @html.button html_opts
        end
      end
    end
  end
end
