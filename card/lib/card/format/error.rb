class Card
  class Format
    module Error
      def rescue_view e, view
        raise e if Rails.env =~ /^cucumber|test$/
        if focal?
          focal_error e, view
        else
          # TODO: consider rendering dynamic error view here.
          nested_error e, view
        end
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

      def focal_error e, view
        card.errors.add view.to_s, e.message if card.errors.empty?
        render Card::Error.exception_view card, e
      end

      def nested_error _exception, view
        I18n.t :error_rendering, scope: [:lib, :card, :format, :error],
               cardname: error_cardname, view: view
      end
    end
  end
end
