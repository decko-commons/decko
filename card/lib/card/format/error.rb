class Card
  class Format
    module Error
      def rescue_view e, view
        method = loud_error? ? :loud_error : :quiet_error
        send method, e, view
      end

      def error_cardname _exception
        if card&.name.present?
          safe_name
        else
          I18n.t :no_cardname, scope: %i[lib card format error]
        end
      end

      def loud_error?
        focal? || Card.config.raise_all_rendering_errors
      end

      def loud_error e, view
        card.errors.add "#{view} view", rendering_error(e, view) if card.errors.empty?
        raise e
      end

      def quiet_error e, view
        # TODO: unify with Card::Error#report
        Rails.logger.info "#{e.message}\n#{e.backtrace}"
        rendering_error e, view
      end

      def rendering_error exception, view
        if exception.is_a? Card::Error::UserError
          exception.message
        else
          tr :error_rendering, scope: [:lib, :card, :format, :error],
                               cardname: error_cardname(exception), view: view
        end
      end
    end
  end
end
