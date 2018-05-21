# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current

    class BadContent < Error
    end

    class BadQuery < Error
    end

    class BadAddress < Error
    end

    class NotFound < StandardError
    end

    class CodenameNotFound < NotFound
    end

    # permission errors
    class PermissionDenied < Error
      attr_reader :card

      def initialize message
        if message.is_a? Card
          super message_from_card(message)
        else
          super
        end
      end

      def message_from_card card
        I18n.t :exception_for_card, scope: [:lib, :card, :error],
                                    cardname: card.name,
                                    message: card.errors[:permission_denied]
      end
    end

    # exception class for aborting card actions
    class Abort < StandardError
      attr_reader :status

      def initialize status, msg=""
        @status = status
        super msg
      end
    end

    # associating views with exceptions
    class << self
      ## NOTE: arguably the view and status should be handled in each error class
      ## status is currently defined in the view

      def exception_view card, exception
        self.current = exception
        simple_exception_view(card, exception) ||
          problematic_exception_view(card, exception)
      end

      def simple_exception_view card, exception
        # "simple" error messages are visible to end users and are generally not
        # treated as software bugs (though they may be "ruler" bugs)
        case exception
        when BadContent, BadQuery
          card.errors.add :exception, exception.message
          :errors
        when BadAddress
          :bad_address
        when PermissionDenied
          :denial
        when NotFound, ActiveRecord::RecordNotFound, ActionController::MissingFile
          :not_found
        end
      end

      # indicates a code problem and therefore require full logging
      def problematic_exception_view card, exception
        card&.notable_exception_raised

        if exception.is_a? ActiveRecord::RecordInvalid
          :errors
        elsif Rails.logger.level.zero?
          # raise error loudly when not in production (could be a better test!)
          raise exception
        else
          :server_error
        end
      end

      # card view and HTTP status code associate with errors on card
      # TODO: should prioritize certain error classes
      def view_and_status card
        card.errors.keys.each do |key|
          if (view_and_status = Card.error_codes[key])
            return view_and_status
          end
        end
        nil
      end
    end
  end
end
