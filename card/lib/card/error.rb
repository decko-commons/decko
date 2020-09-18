# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current
    class_attribute :status_code, :view
    attr_writer :backtrace

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

    def backtrace
      @backtrace || super
    end

    def report
      Rails.logger.info "exception = #{self.class}: #{message}"
      Rails.logger.debug backtrace.join("\n")
    end

    def card_message_text
      card.errors.first&.message
    end

    # error attributable to code (as opposed to card configuration)
    class ServerError < Error
      def self.view
        debugger_on? ? :debug_server_error : :server_error
      end

      def self.status_code
        # Errors with status code 900 are displayed as modal instead of inside
        # the "card-notice" div``
        debugger_on? ? 900 : 500
      end

      def self.debugger_on?
        Card::Codename[:debugger] && Card[:debugger]&.content =~ /on/
      end

      def report
        super
        card&.notable_exception_raised
      end
    end

    # error whose message can be shown to any user
    # ARDEP: exceptions RecordNotFound, RecordInvalid
    # ARDEP ActionController: exceptions BadRequest, MissingFile
    class UserError < Error
      cattr_accessor :user_error_classes
      self.user_error_classes = [self,
                                 ActionController::BadRequest,
                                 ActionController::MissingFile,
                                 ActiveRecord::RecordNotFound,
                                 ActiveRecord::RecordInvalid]
    end

    # error in CQL query
    class BadQuery < UserError
    end

    class BadAddress < UserError
      self.status_code = 404
      self.view = :bad_address
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

      def report
        Rails.logger.debug "aborting: #{message}"
      end

      def initialize status, msg=""
        @status = status
        super msg
      end
    end

    # associating views with exceptions
    class << self
      KEY_MAP = { permission_denied: PermissionDenied,
                  conflict: EditConflict }.freeze

      def report exception, card
        e = cardify_exception exception, card
        self.current = e
        e.report
        e
      end

      def cardify_exception exception, card
        card_exception =
          if exception.is_a? Card::Error
            exception
          else
            card_error_class(exception, card).new exception.message
          end
        card_exception.card ||= card
        card_exception.backtrace ||= exception.backtrace
        add_card_errors card, card_exception if card.errors.empty?
        card_exception
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
