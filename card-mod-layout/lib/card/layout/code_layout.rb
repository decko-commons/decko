class Card
  class Layout
    class CodeLayout < Layout
      def render
        @format.send Card::Set::Format.layout_method_name(@layout)
      end
    end
  end
end
