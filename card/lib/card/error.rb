# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current
    class_attribute :status, :message, :view

    self.view = :errors
    self.status = 500

    def initialize message, error_status=nil
      self.status = error_status
      super message.is_a?(Card) ? message_from_card(message) : message
    end

    def message_from_card card
      I18n.t :exception_for_card, scope: %i[lib card error],
                                  cardname: card.name,
                                  message: card.errors[:permission_denied]
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

    class NotFound < Error
      self.status = 404
      self.view = :not_found
    end

    class CodenameNotFound < NotFound
    end

    # permission errors
    class PermissionDenied < OpenError
      self.status = 403
      self.view = :denial
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
