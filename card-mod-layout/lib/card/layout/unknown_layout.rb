class Card
  class Layout
    class UnknownLayout < Layout
      def render
        @format.output [header, text]
      end

      def header
        @format.content_tag :h1, @format.tr(:unknown_layout,
                                            scope: "card-mod-format", name: @layout)
      end

      def text
        @format.tr(:available_layouts, scope: "card-mod-format",
                                       available_layouts: self.class.built_in_layouts)
      end
    end
  end
end
