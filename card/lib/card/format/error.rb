class Card
  class Format
    # permissions and errors in card format classes
    module Error
      def ok? task
        task = :create if task == :update && card.new_card?
        card.ok? task
      end

      def anyone_can? task
        return false unless task.is_a? Symbol

        @anyone_can ||= {}
        @anyone_can[task] = card.anyone_can? task if @anyone_can[task].nil?
        @anyone_can[task]
      end

      def view_for_unknown setting_view
        if main? && voo.root?
          root.error_status = page_status_for_unknown
          page_view_for_unknown
        else
          setting_view || :unknown
        end
      end

      def view_for_denial view, task
        @denied_task = task
        root.error_status = 403 if focal? && voo.root?
        view_setting(:denial, view) || :denial
      end

      def monitor_depth
        max = Card.config.max_depth
        if depth >= max || voo.depth >= max
          raise Card::Error::UserError, t(:format_too_deep)
        end

        yield
      end

      private

      def rescue_view e, view
        method = loud_error? ? :loud_error : :quiet_error
        send method, e, view
      end

      def page_status_for_unknown
        404
      end

      def page_view_for_unknown
        :not_found
      end

      def error_cardname _exception
        if card&.name.present?
          safe_name
        else
          ::I18n.t :lib_no_cardname
        end
      end

      def loud_error?
        focal? || Card.config.raise_all_rendering_errors
      end

      def loud_error e, view
        e.report if focal? && voo.root?
        card.errors.add "#{view} view", rendering_error(e, view) if card.errors.empty?
        raise e
      end

      def quiet_error e, view
        e.report
        rendering_error e, view
      end

      def rendering_error exception, view
        if exception.is_a? Card::Error::UserError
          exception.message
        else
          t :lib_error_rendering, cardname: error_cardname(exception), view: view
        end
      end
    end
  end
end
