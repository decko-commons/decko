class Card
  class Action
    # supports rendering action details within ui
    class ActionRenderer
      attr_reader :action, :header

      def initialize format, action, header=true, action_view=:summary, hide_diff=false
        @format = format
        @action = action
        @header = header
        @action_view = action_view
        @hide_diff = hide_diff
      end

      include Card::Bootstrapper

      def method_missing(method_name, *, &)
        if block_given?
          @format.send(method_name, *, &)
        else
          @format.send(method_name, *)
        end
      end

      def respond_to_missing? method_name, _include_private=false
        @format.respond_to? method_name
      end

      def render
        classes = @format.classy("action-list")
        bs_layout container: true, fluid: true do
          row do
            html <<-HTML
              <ul class="#{classes} w-100">
                <li class="#{action.action_type}">
                  #{action_panel}
                </li>
              </ul>
            HTML
          end
        end
      end

      def action_panel
        bs_panel do
          if header
            heading do
              div type_diff, class: "float-end"
              div name_diff
            end
          end
          body do
            content_diff
          end
        end
      end

      def relative_name
        @action.card.name.from @format.card.name
      end

      def name_diff
        return relative_name if @action.card.name.compound?

        # TODO: handle compound names better

        # if @action.card == @format.card
        name_changes

        # I commented out the following because it's hard to imagine it working; there
        # no "related" view! But perhaps we do still need handling for this case, which
        # is evidently for when there is a change involving a simple card that is not the
        # act card??
        #
        # else
        #   link_to_view(
        #     :related, name_changes,
        #     path: { slot: { items: { view: "history", nest_name: @action.card.name } } }
        #     # "data-slot-selector" => ".card-slot.history-view"
        #   )
        # end
      end

      def content_diff
        return @action.raw_view if @action.action_type == :delete

        @format.subformat(@action.card).render_action_summary action_id: @action.id
      end

      def type_diff
        return "" unless @action.new_type?

        @hide_diff ? @action.value(:cardtype) : @action.cardtype_diff
      end

      def name_changes
        return old_name unless @action.new_name?

        @hide_diff ? new_name : Card::Content::Diff.complete(old_name, new_name)
      end

      def old_name
        (name = @action.previous_value :name) && title_in_context(name)
      end

      def new_name
        title_in_context @action.value(:name)
      end
    end
  end
end
