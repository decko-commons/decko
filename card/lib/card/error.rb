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

    def initialize message
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

    def report!
      Rails.logger.info "exception = #{self.class}: #{message}"
    end

    def card_message_text
      card.errors.first&.message
    end

    # error attributable to code (as opposed to card configuration)
    class ServerError < Error
      self.view = :server_error
      self.status_code = 500

      def report!
        super
        card&.notable_exception_raised
      end
    end

    class OpenError < Error
    end

    class ViewError < OpenError
    end

    class BadContent < OpenError
    end

    class BadQuery < OpenError
    end

    # card not found
    class NotFound < Error
      self.status_code = 404
      self.view = :not_found
    end

    class CodenameNotFound < NotFound
    end

    # permission errors
    class PermissionDenied < OpenError
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
      def cardify_exception exception, card
        unless exception.is_a? Card::Error
          exception = card_error_class(exception).new exception.message
        end
        exception.card ||= card
        exception
      end

      def card_error_class exception
        case exception
        when ActiveRecord::RecordInvalid
          Card::Error
        when ActiveRecord::RecordNotFound, ActionController::MissingFile
          Card::Error::NotFound
        else
          Card::Error::ServerError
        end
      end
    end
  end
end
