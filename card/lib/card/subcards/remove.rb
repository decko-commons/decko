class Card
  class Subcards
    # Methods for removing/clearing subcards
    module Remove
      def remove_child cardish
        child = cardish.is_a?(Card) ? cardish : child(cardish)
        remove child
      end
      alias_method :remove_field, :remove_child

      def remove name_or_card
        key = subcard_key name_or_card
        return unless @keys.include? key

        @keys.delete key
        clear_key key
      end

      def clear
        @keys.each { |key| clear_key key }
        @keys = ::Set.new
      end

      def clear_key key
        if (subcard = fetch_subcard key)
          Director.deep_delete subcard.director
          subcard.current_action&.delete
        end
        Card.cache.soft.delete key
        subcard
      end

      def deep_clear cleared=::Set.new
        each_card do |card|
          next if cleared.include? card.id

          cleared << card.id
          card.subcards.deep_clear cleared
        end
        clear
      end
    end
  end
end
