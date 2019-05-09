class Card
  class Format
    module Permission
      def ok_view view, skip_perms=false
        raise Card::Error::UserError, tr(:too_deep) if subformats_nested_too_deeply?

        approved_view = check_view view, skip_perms
        @denied_view = view unless approved_view == view
        approved_view
      end

      def ok? task
        task = :create if task == :update && card.new_card?
        @ok ||= {}
        @ok[task] = card.ok? task if @ok[task].nil?
        @ok[task]
      end

      private

      def check_view view, skip_perms
        case
        when skip_perms                       then view
        when view_always_permitted?(view)     then view
        when unknown_disqualifies_view?(view) then view_for_unknown view
        else permitted_view view  # run explicit permission checks
        end
      end

      def unknown_disqualifies_view? view
        # view can't handle unknown cards (and card is unknown)
        return false if view_setting(:unknown, view)

        card.unknown?
      end

      def subformats_nested_too_deeply?
        # prevent recursion
        depth >= Card.config.max_depth
      end

      def view_always_permitted? view
        view_setting(:perms, view) == :none
      end

      def permitted_view view
        if (@denied_task = task_denied_for_view view)
          deny_view view
        else
          view
        end
      end

      def deny_view view
        root.error_status = 403 if focal? && voo.root?
        view_setting(:denial, view) || :denial
      end

      def task_denied_for_view view
        perms = view_setting(:perms, view) || :read
        if perms.is_a? Proc
          :read unless perms.call(self)  # read isn't quite right
        else
          Array.wrap(perms).select { |task| !ok? task }
        end
      end

      def view_for_unknown _view
        # note: overridden in HTML
        if main?
          root.error_status = 404
          :not_found
        else
          :missing
        end
      end
    end
  end
end
