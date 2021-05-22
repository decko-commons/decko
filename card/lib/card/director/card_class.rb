class Card
  class Director
    # director-related Card class methods
    module CardClass
      def create! opts
        card = Card.new opts
        card.save!
        card
      end

      def create opts
        card = Card.new opts
        card.save
        card
      end
    end
  end
end
