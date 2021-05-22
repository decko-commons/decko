class Card
  class Layout
    class ProcLayout < Layout
      def render
        @layout.call
      end
    end
  end
end
