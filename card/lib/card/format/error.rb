class Card
  class Format
    module Error
      def rescue_view e, view
        raise e if Rails.env =~ /^cucumber|test$/
        error_view = Card::Error.exception_view @card, e
        # TODO: consider rendering dynamic error view here.
        rendering_error e, view
      end

      def debug_error e
        raise e if Card[:debugger]&.content == "on"
      end

      def error_cardname
        if card&.name.present?
          safe_name
        else
          I18n.t :no_cardname, scope: [:lib, :card, :format, :error]
        end
      end

      def rendering_error _exception, view
        I18n.t :error_rendering, scope: [:lib, :card, :format, :error],
               cardname: error_cardname, view: view
      end
    end
  end
end
