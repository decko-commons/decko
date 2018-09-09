# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current
    class_attribute :status_code, :view

    self.view = :errors
    self.status_code = 500

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

    def card_message_text
      card.errors.first.message
    end

    class OpenError < Error
    end

    class ViewError < OpenError
    end

    class BadContent < OpenError
    end

    class BadQuery < OpenError
    end

    class ServerError < Error
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
        card.errors[:permission].message
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

      def cardify_exception exception
        return exception if exception.is_a? Card::Error
        card_exception_class(exception).new exception.message
      end

      def card_exception_class exception
        case exception
        when ActiveRecord::RecordNotFound, ActionController::MissingFile
          Card::NotFound
        else
          Card::ServerError
        end
      end
    end
  end
end
