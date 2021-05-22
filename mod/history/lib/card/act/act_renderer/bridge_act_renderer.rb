class Card
  class Act
    class ActRenderer
      # Used for the bridge
      class BridgeActRenderer < RelativeActRenderer
        def title
          wrap_with(:div, left_title, class: "mr-2") +
            wrap_with(:div, right_title, class: "ml-auto act-summary")
        end

        def left_title
          ["##{@args[:act_seq]}", @act.actor.name, wrap_with(:small, edited_ago)].join " "
        end

        def right_title
          summary
        end

        def render
          return "" unless @act_card

          details
        end

        def bridge_link
          opts = @format.bridge_link_opts(
            path: { act_id: @act.id, view: :bridge_act, act_seq: @args[:act_seq] },
            "data-toggle": "pill"
          )
          add_class opts, "d-flex nav-link"
          opts[:path].delete :layout
          link_to_card @card, title, opts
        end

        def overlay_title
          wrap_with :div do
            [left_title, summary,
             subtitle.present? ? subtitle : nil,
             rollback_or_edit_link].compact.join " | "
          end
        end

        def rollback_or_edit_link
          if @act.draft?
            autosaved_draft_link text: "continue editing"
          elsif show_rollback_link?
            revert_link
          end
        end
      end
    end
  end
end
