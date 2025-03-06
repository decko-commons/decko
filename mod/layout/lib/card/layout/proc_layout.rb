class Card
  class Layout
    # card layouts defined by ruby procs
    class ProcLayout < Layout
      def render
        @layout.call
      end
    end
  end
end
