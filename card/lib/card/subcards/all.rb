class Card
  class Subcards
    # subcard-related Card instance methods
    module All
      def subcard card_name, args={}
        if (sc = subcards.card card_name)
          sc.assign_attributes args
          sc
        else
          subcards.add card_name, args
        end
      end

      def subcard? card_name
        subcards.card(card_name).present?
      end

      def subfield field_name
        subcards.field field_name
      end

      def field? tag
        field(tag) || subfield(tag)
      end

      def subcards
        @subcards ||= Card::Subcards.new self
      end

      def subcards?
        subcards.present?
      end

      def expire_subcards
        subcards.clear
      end

      # phase_method :attach_subfield, before: :approve do |name_or_card, args=nil|
      def attach_subfield name_or_card, args={}
        subcards.add_field name_or_card, args
      end
      alias_method :add_subfield, :attach_subfield

      def attach_subfield! name_or_card, args={}
        subcard = subcards.add_field name_or_card, args
        subcard.director.reset_stage
        subcard
      end

      def detach_subcard name_or_card
        subcards.remove name_or_card
      end
      alias_method :remove_subcard, :detach_subcard

      def detach_subfield name_or_card
        subcards.remove_field name_or_card
      end
      alias_method :remove_subfield, :detach_subfield

      def clear_subcards
        subcards.clear
      end

      # ensures subfield is present
      # does NOT override subfield content if already present
      def ensure_subfield field_name, args={}
        if subfield_present? field_name
          subfield field_name
        else
          add_subfield field_name, args
        end
      end

      def subfield_present? field_name
        subfield(field_name)&.content&.present?
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
