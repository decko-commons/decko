class Card
  class Format
    module Error
      def rescue_view e, view
        # make config option; don't refer directly to env
        raise e if Rails.env =~ /^cucumber$/
        # TODO: unify with Card::Error#report
        Rails.logger.info "#{e.message}\n#{e.backtrace}"
        method = focal? ? :focal_error : :rendering_error
        send method, e, view
      end

      def error_cardname _exception
        if card&.name.present?
          safe_name
        else
          I18n.t :no_cardname, scope: %i[lib card format error]
        end
      end

      def focal_error e, view
        card.errors.add "#{view} view", rendering_error(e, view) if card.errors.empty?
        raise e
      end

      def rendering_error exception, view
        if exception.is_a? Card::Error::OpenError
          exception.message
        else
          tr :error_rendering, scope: [:lib, :card, :format, :error],
                               cardname: error_cardname(exception), view: view
        end
      end
    end
  end
end
