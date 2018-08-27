class Card
  class Layout
    class UnknownLayout < Layout
      def render
        scope = "mod.core.format.html_format"
        @format.output [
                         @format.content_tag(:h1, @format.tr(:unknown_layout, scope: scope, name: @layout)),
                         @format.tr(:available_layouts, scope: scope,
                                    available_layouts: self.class.built_in_layouts)
                       ]
      end
    end
  end
end
