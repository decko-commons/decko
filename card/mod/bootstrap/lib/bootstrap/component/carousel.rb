class Bootstrap
  class Component
    class Carousel < Component
      def render_content *args
        carousel *args, &@build_block
      end

      add_div_method :carousel, "carousel slide" do |opts, extra_args |
        prepend { indicators }
        opts
      end

      add_div_method :carousal_items, 'carousel-inner' do |opts, extra_args|

      end

      add_div_method :item, nil do |opts, extra_args|
        html "<div class='carousel slide' id='csID'><ol class='carousel-indicators'></ol></div>"
        opts
      end

      add_div_method :controls, nil do |opts, extra_args|

      end

      add_tag_method :a, :control_prev, 'carousel-control-prev' do |opts, extra_args|

      end

      add_tag_method :a, :control_next, 'carousel-control-next' do |opts, extra_args|

      end

      add_div_method :indicators, 'carousel-indicators' do |opts, extra_args|
        opts
      end
    end
  end
end