class Card
  class Subcards
    # subcard-related Card instance methods
    module All
      def subcards
        @subcards ||= Card::Subcards.new self
      end

      def subcards?
        subcards.present?
      end

      def subcard card_name, args={}
        if (sc = subcards.card card_name)
          sc.assign_attributes args
          sc
        else
          subcards.add card_name, args
        end
      end

      def subcard_content card_name
        subcards.card(card_name)&.content
      end

      def subcard? card_name
        subcards.card(card_name).present?
      end

      def field field_name, args={}
        if (sf = subcards.field field_name)
          sf.assign_attributes args
          sf
        else
          subcards.add_field field_name, args
        end
      end

      def field_content field_name
        subcards.field(field_name)&.content
      end

      def field? tag
        fetch(tag) || subcards.field(tag).present?
      end

      def drop_subcard name_or_card
        subcards.remove name_or_card
      end

      def drop_field name_or_card
        subcards.remove_field name_or_card
      end

      def handle_subcard_errors
        subcards.each do |subcard|
          subcard.errors.each do |error|
            subcard_error subcard, error
          end
          subcard.errors.clear
        end
      end

      private

      def subcard_error subcard, error
        msg = error.message
        msg = "#{error.attribute} #{msg}" unless %i[content abort].member? error.attribute
        errors.add subcard.name.from(name), msg
      end
    end
  end
end
