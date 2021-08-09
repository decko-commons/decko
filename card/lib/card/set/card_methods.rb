class Card
  module Set
    module CardMethods
      include Event::All
      include Pattern::All

      delegate :basket, to: Set
    end
  end
end
