class Card
  class Layout
    # handling for layout specified but unknown
    class UnknownLayout < Layout
      delegate :t, to: Cardio

      def render
        @format.output [header, text]
      end

      def header
        @format.content_tag :h1, t(:layout_unknown_layout, name: @layout)
      end

      def text
        t :layout_available_layouts, available_layouts: self.class.built_in_layouts
      end
    end
  end
end
