class Bootstrap
  class Component
    class Carousel < Component
      def render_content
        carousel *@args, &@build_block
      end

      add_div_method :carousel, "carousel slide" do |opts, extra_args |
        id, item_cnt = extra_args

        insert do
          indicators id, item_cnt, opts.delete(:active)
          control_prev id
          control_next id
        end
        opts.merge id: id
      end

      add_div_method :inner, 'carousel-inner'

      add_div_method :item, 'carousel-item' do |opts, extra_args|
        add_class opts, "active"
        opts
      end

      add_tag_method :control_prev, 'carousel-control-prev', tag: :a do |opts, extra_args|
        id = extra_args.first
        insert do
          <<-HTML
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="sr-only">Previous</span>
          HTML
        end
        opts.merge(href: "##{id}", role: "button", data: { slide: "prev" } )
      end

      add_tag_method :control_next,  'carousel-control-next', tag: :a do |opts, extra_args|
        id = extra_args.first
        insert do
          <<-HTML
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="sr-only">Next</span>
          HTML
        end
        opts.merge(href: "##{id}", role: "button", data: { slide: "next" } )
      end

      add_tag_method :indicators, 'carousel-indicators', tag: :ol do |opts, extra_args|
        id, item_cnt, active  = extra_args
        insert do
          item_cnt.times do |i|
            indicator id, i, i == active
          end
        end
        opts
      end

      add_tag_method :indicator, nil, tag: :li do |opts, extra_args|
        id, index, active = extra_args
        add_class opts, "active" if active
        opts.merge data: { "slide-to" => index, target: "##{id}" }
      end
    end
  end
end