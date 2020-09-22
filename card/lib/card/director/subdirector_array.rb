class Card
  class Director
    class SubdirectorArray < Array
      def self.initialize_with_subcards parent
        dir_array = new(parent)
        parent.card.subcards.each_card do |subcard|
          dir_array.add subcard
        end
        dir_array
      end

      def initialize parent
        @parent = parent
        super()
      end

      def add card
        card = card.card if card.is_a? Director
        existing(card) || fetch_new(card)
      end

      alias_method :delete_director, :delete

      def delete card
        if card.is_a? Director
          delete_director card
        else
          delete_if { |dir| dir.card == card }
        end
      end

      private

      def existing card
        find { |dir| dir.card == card }
      end

      def fetch_new card
        Director.fetch(card, @parent).tap do |dir|
          update dir, card unless dir.main?
        end
      end

      def update dir, card
        dir.replace_card card if dir.card != card
        dir.parent = @parent
        self << dir
      end
    end
  end
end
