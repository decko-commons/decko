# -*- encoding : utf-8 -*-

class Card
  # Model for the card_virtuals table.
  # It provides method to get and store content for virtual cards from
  # the card_virtuals table.
  class Virtual < Cardio::Record
    def update new_content
      content == new_content ? touch : update!(content: new_content)
      new_content
    end

    class << self
      def fetch card
        cache.fetch card.key do
          find_by_card(card) || create(card)
        end
      end

      def save card
        virt = find_by_card card
        virt ? virt.update(card.virtual_content) : create(card)
        cache.write card.key, virt
      end

      def delete card
        find_by_card(card)&.delete
        cache.delete card.key
      end

      private

      def cache
        Card::Cache[Virtual]
      end

      def create card
        validate_card card
        create! left_id: left_id(card),
                right_id: right_id(card),
                left_key: card.name.left_key,
                content: card.virtual_content
      end

      def find_by_card card
        where_card(card).take
      end

      def where_card card
        query = { right_id: right_id(card) }
        if (lid = left_id(card))
          query[:left_id] = lid
        else
          query[:left_key] = card.name.left_key
        end
        where query
      end

      def left_id card
        if card.compound?
          card.left_id&.positive? ? card.left_id : card.left&.id
        else
          card.id
        end
      end

      def right_id card
        if card.compound?
          card.right_id&.positive? ? card.right_id : card.right&.id
        else
          -2
        end
      end

      def validate_card card
        reason ||=
          if card.compound?
            "needs left_id" unless left_id(card)
            "needs right_id" unless right_id(card)
          elsif !card.id
            "needs id"
          end
        return unless reason

        raise Card::Error, card.name, "count not cacheable: card #{card.name} #{reason}"
      end
    end
  end
end
