# Decko's only controller.
class CardController
  # controller error handling
  module Errors
    # controller class method to handle top-level error rescuing
    module Rescue
      def rescue_from_class *klasses
        klasses.each do |klass|
          rescue_from(klass) { |exception| handle_exception exception }
        end
      end

      def rescue_all?
        Cardio.config.rescue_all_in_controller
      end
    end

    def handle_exception exception
      raise exception if debug_exception?(exception)

      @card ||= Card.new
      error = Card::Error.report exception, card
      show error.class.view, error.class.status_code
    end

    # TODO: move to exception object
    def debug_exception? e
      !e.is_a?(Card::Error::UserError) &&
        !e.is_a?(ActiveRecord::RecordInvalid) &&
        Card::Codename[:debugger] &&
        Card[:debugger]&.content =~ /on/  # && !Card::Env.ajax?
    end
  end
end
