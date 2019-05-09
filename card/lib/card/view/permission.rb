class Card
  class View
    # View permissions support view-specific permission handling
    #
    # Views can be configured in {Set::Format::AbstractFormat#view view definitions}
    # with the `perms` directive, eg
    #
    #         # only render if user has permission to update card
    #         view :myview, perms: :update do...
    module Permission
      private

      def approve_view
        raise Card::Error::UserError, tr(:too_deep) if format_too_deep?
        altered_view || requested_view
      end

      def view_perms
        @view_perms = setting(:perms) || :read
      end

      def altered_view
        case
        when skip_check?           then nil
        when unknown_disqualifies? then format.view_for_unknown requested_view
        when (task = denied_task)  then format.view_for_denial requested_view, task
        end
      end

      def skip_check?
        normalized_options[:skip_perms] || view_perms == :none
      end

      def setting setting_name
        format.view_setting setting_name, requested_view
      end

      # by default views can't handle unknown cards, but this can be overridden in
      # view definitions with the `unknown` directive
      def unknown_disqualifies?
        setting(:unknown) ? false : card.unknown?
      end

      # catch recursion
      def format_too_deep?
        format.depth >= Card.config.max_depth
      end

      def denied_task
        if view_perms.is_a? Proc
          :read unless view_perms.call(format)  # read isn't quite right
        else
          Array.wrap(view_perms).find { |task| !format.ok? task }
        end
      end
    end
  end
end
