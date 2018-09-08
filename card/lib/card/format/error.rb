class Card
  class Format
    module Error
      def rescue_view e, view
        binding.pry
        # make config option; don't refer directly to env
        raise e if Rails.env =~ /^cucumber|test$/
        method = focal? ? :focal_error : :rendering_error
        send method, e, view
      end

      def error_cardname
        if card&.name.present?
          safe_name
        else
          I18n.t :no_cardname, scope: [:lib, :card, :format, :error]
        end
      end

      def focal_error e, view
        card.errors.add :view, rendering_error(e, view) if card.errors.empty?
        raise e
      end

      def rendering_error _exception, view
        tr :error_rendering, scope: [:lib, :card, :format, :error],
                             cardname: error_cardname, view: view
      end
    end
  end
end
