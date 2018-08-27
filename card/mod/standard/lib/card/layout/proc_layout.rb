class Card
  class Layout
    class ProcLayout < Layout
      def render
        if @format.voo.main && !@format.already_mained?
          @format.wrap_main { @layout.call }
        else
          @layout.call
        end
      end
    end
  end
end
