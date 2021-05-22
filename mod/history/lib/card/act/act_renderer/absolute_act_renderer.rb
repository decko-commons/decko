class Card
  class Act
    class ActRenderer
      # Used for recent changes.
      # It shows all actions of an act
      class AbsoluteActRenderer < ActRenderer
        def title
          absolute_title
        end

        def subtitle
          wrap_with :small do
            [
              @format.link_to_card(@act.actor, nil, class: "_stop_propagation"),
              edited_ago,
              rollback_link
            ]
          end
        end

        # FIXME: how do we know we need main here??
        def revert_link
          revert_actions_link "revert to previous",
                              { revert_to: :previous, revert_act: @act.id },
                              { "data-slot-selector": "#main > .card-slot" }
        end

        def actions
          @act.actions
        end
      end
    end
  end
end
