class Card
  module Set
    module CardMethods
      include Event::All
      include Pattern::All

      def basket
        Set.basket
      end
    end
  end
end
