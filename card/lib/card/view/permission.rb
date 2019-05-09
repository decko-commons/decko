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
        return if skip_check?
        alter_unknown || denial
      end

      def skip_check?
        normalized_options[:skip_perms] || view_perms == :none
      end

      def setting setting_name, view=nil
        view ||= requested_view
        format.view_setting setting_name, view
      end

      # by default views can't handle unknown cards, but this can be overridden in
      # view definitions with the `unknown` directive
      def alter_unknown
        setting = setting(:unknown)
        return if setting == true || card.known?
        setting.is_a?(Symbol) ? setting : format.view_for_unknown(requested_view)
      end

      # catch recursion
      def format_too_deep?
        format.depth >= Card.config.max_depth
      end

      def denial
        return unless (task = denied_task)

        format.view_for_denial requested_view, task
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
