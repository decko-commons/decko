class Card
  class Format
    module Permission
      def ok_view view, skip_perms=false
        raise Card::Error::OpenError, tr(:too_deep) if subformats_nested_too_deeply?
        approved_view = check_view view, skip_perms
        handle_view_denial view, approved_view
        approved_view
      end

      def handle_view_denial view, approved_view
        return if approved_view == view
        @denied_view = view
      end

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
        return if tagged view, :unknown_ok
        card.unknown?
      end

      def subformats_nested_too_deeply?
        # prevent recursion
        depth >= Card.config.max_depth
      end

      def view_always_permitted? view
        Card::Format.perms[view] == :none
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
        Card::Format.denial[view] || :denial
      end

      def task_denied_for_view view
        perms_required = Card::Format.perms[view] || :read
        if perms_required.is_a? Proc
          :read unless perms_required.call(self)  # read isn't quite right
        else
          [perms_required].flatten.find { |task| !ok? task }
        end
      end

      def view_for_unknown _view
        # note: overridden in HTML
        root.error_status = 404 if focal?
        focal? ? :not_found : :missing
      end

      def ok? task
        task = :create if task == :update && card.new_card?
        @ok ||= {}
        @ok[task] = card.ok? task if @ok[task].nil?
        @ok[task]
      end
    end
  end
end
