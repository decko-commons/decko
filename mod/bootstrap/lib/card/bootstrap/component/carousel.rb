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

          @html.div class: "carousel slide", id: id, "data-ride" => "carousel" do
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
          @html.div class: "carousel-inner", role: "listbox" do
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
          @html.a class: "carousel-control-prev", href: "##{@id}", role: "button",
                  "data-slide" => "prev" do
            @html.span class: "carousel-control-prev-icon", "aria-hidden" => "true"
            @html.span "Previous", class: "sr-only"
          end
        end

        def control_next
          @html.a class: "carousel-control-next", href: "##{@id}", role: "button",
                  "data-slide": "next"  do
            @html.span class: "carousel-control-next-icon", "aria-hidden" => "true"
            @html.span "Next", class: "sr-only"
          end
        end

        def indicators
          @html.ol class: "carousel-indicators" do
            @items.size.times { |i| indicator i }
          end
        end

        def indicator index
          html_opts = { "data-slide-to" => index, "data-bs-target": "##{@id}" }
          add_class html_opts, "active" if index == @active_item_index
          @html.li html_opts
        end
      end
    end
  end
end
