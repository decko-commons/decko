class Card
  class Act
    class ActRenderer
      # Use for the history for one specific card
      # It shows only the actions of an act that are relevant
      # for the card of the format that renders the act.
      class RelativeActRenderer < ActRenderer
        def title
          "<span class=\"nr\">##{@args[:act_seq]}</span>#{accordion_expand_link(@act.actor.name)} #{wrap_with(
            :small, edited_ago
          )}"
        end

        def subtitle
          return "" unless @act.card_id != @format.card.id

          wrap_with :small, "act on #{absolute_title}"
        end

        def act_links
          return unless (content = rollback_or_edit_link)

          wrap_with :small, content
        end

        def rollback_or_edit_link
          if @act.draft?
            autosaved_draft_link text: "continue editing",
                                 class: "collapse #{collapse_id}"
          elsif show_rollback_link?
            rollback_link
          end
        end

        def show_rollback_link?
          !current_act?
        end

        def current_act?
          return unless @format.card.last_act && @act

          @act.id == @format.card.last_act.id
        end

        def actions
          @actions ||= @act.actions_affecting(@card)
        end

        def revert_link
          revert_actions_link "revert to this",
                              { revert_actions: actions.map(&:id) },
                              class: "_close-modal",
                              "data-slotter-mode": "update-modal-origin"
        end
      end
    end
  end
end
