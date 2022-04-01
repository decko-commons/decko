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
      CRUD = ::Set.new(%i[create read update delete]).freeze

      def view_perms
        @view_perms = setting(:perms) || :read
      end

      private

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

      # views for unknown cards can be configured in view definitions
      # or render/nest options (the latter take precedence)
      def alter_unknown
        return if card.known?

        unknown_setting = setting :unknown
        return if unknown_setting&.to_s == "true" # requested view supports unknown

        configured_view = (unknown || unknown_setting)&.to_sym
        format.view_for_unknown configured_view
      end

      def denial
        return unless (task = denied_task)

        format.view_for_denial requested_view, task
      end

      def crud? task
        task.in? CRUD
      end

      def denied_task
        Array.wrap(view_perms).find do |task|
          if crud? task
            !format.ok? task
          else
            !format.send task
          end
        end
      end
    end
  end
end
