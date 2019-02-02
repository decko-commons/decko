class Card
  class Layout
    class UnknownLayout < Layout
      SCOPE = "mod.core.format.html_format".freeze

      def render
        @format.output [header, text]
      end

      def header
        @format.content_tag(:h1, @format.tr(:unknown_layout, scope: SCOPE, name: @layout))
      end

      def text
        @format.tr(:available_layouts, scope: SCOPE,
                                       available_layouts: self.class.built_in_layouts)
      end
    end
  end
end
