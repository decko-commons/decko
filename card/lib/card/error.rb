# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current
    class_attribute :status_code, :view

    self.view = :errors
    self.status_code = 422

    attr_accessor :card

    def initialize message=nil
      if message.is_a? Card
        self.card = message
        message = message_from_card
      end
      super message
    end

    def message_from_card
      I18n.t :exception_for_card,
             scope: %i[lib card error], cardname: card.name, message: card_message_text
    end

    def report
      Rails.logger.info "exception = #{self.class}: #{message}"
    end

    def card_message_text
      card.errors.first&.message
    end

    # error attributable to code (as opposed to card configuration)
    class ServerError < Error
      self.view = :server_error
      self.status_code = 500

      def report
        super
        card&.notable_exception_raised
      end
    end

    # error whose message can be shown to any user
    class UserError < Error
    end

    # error in WQL query
    class BadQuery < UserError
    end

    # card not found
    class NotFound < UserError
      self.status_code = 404
      self.view = :not_found
    end

    class CodenameNotFound < NotFound
        end

    # two editors altering the same card at once
    class EditConflict < UserError
      self.status_code = 409
      self.view = :conflict
      end

    # permission errors
    class PermissionDenied < UserError
      self.status_code = 403
      self.view = :denial

      def card_message_text
        card.errors[:permission_denied]
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
      KEY_MAP = { permission_denied: PermissionDenied,
                  conflict: EditConflict }.freeze

      def cardify_exception exception, card
        unless exception.is_a? Card::Error
          exception = card_error_class(exception, card).new exception.message
        end
        exception.card ||= card
        add_card_errors card, exception if exception.card.errors.empty?
        exception
      end

      def add_card_errors card, exception
        label = exception.class.to_s.split("::").last
        card.errors.add label, exception.message
      end

      def card_error_class exception, card
        # "simple" error messages are visible to end users and are generally not
        # treated as software bugs (though they may be "shark" bugs)
        case exception
        when ActiveRecord::RecordInvalid
          invalid_card_error_class card
        when ActiveRecord::RecordNotFound, ActionController::MissingFile
          Card::Error::NotFound
        else
          Card::Error::ServerError
        end
      end

      def invalid_card_error_class card
        KEY_MAP.each do |key, klass|
          return klass if card.errors.key? key
          end
        Card::Error
      end
    end
  end
end
