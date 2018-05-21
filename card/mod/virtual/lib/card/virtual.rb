# -*- encoding : utf-8 -*-

class Card
  # Model for the card_virtuals table.
  # It provides method to get and store content for virtual cards from
  # the card_virtuals table.
  class Virtual < ApplicationRecord
    def update new_content
      update_attributes! content: new_content
      new_content
    end

    class << self
      def create card, virtual_content=nil
        validate_card card
        virtual_content ||= block_given? ? yield : card.generate_virtual_content
        virtual = new left_id: left_id(card), right_id: right_id(card),
                      content: virtual_content
        virtual.save!
        virtual
      end

      def fetch_content card, &block
        find_content_by_card(card) || create(card, &block).content
      end

      def fetch card, &block
        find_by_card(card) || create(card, &block)
      end

      def refresh card
        virtual = find_by_card(card)
        return create(card) unless virtual
        virtual.update card.generate_virtual_content
      end

      def find_content_by_card card
        where_card(card).pluck(:content).first
      end

      def find_by_card card
        where_card(card).take
      end

      private

      def where_card card
        where left_id: left_id(card), right_id: right_id(card)
      end

      def left_id card
        if card.junction?
          card.left_id || ((l = card.left) && l.id)
        else
          card.id
        end
      end

      def right_id card
        if card.junction?
          card.right_id || ((r = card.right) && r.id)
        else
          -1
        end
      end

      def validate_card card
        reason ||=
          if card.junction?
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
