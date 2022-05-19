class Card
  class Act
    class ActRenderer
      def initialize format, act, args
        @format = format
        @act = act
        @act_card = act.card
        @args = args
        @card = @format.card
        @context = @args[:act_context]
      end

      include Card::Bootstrapper

      def method_missing method_name, *args, &block
        if block_given?
          @format.send(method_name, *args, &block)
        else
          @format.send(method_name, *args)
        end
      end

      def respond_to_missing? method_name, _include_private=false
        @format.respond_to? method_name
      end

      def render
        @act_card ? accordion_item : ""
      end

      def header
        # Card::Bootstrap.new(self).render do
        bs_layout do
          row xs: [8, 4], class: "w-100" do
            column do
              html title
              tag(:span, "text-muted ps-1 badge") { summary }
            end
            column subtitle, class: "text-end"
          end
        end
        # end
      end

      def absolute_title
        @act_card.name
      end

      def actor_and_ago
        wrap_with :small do
          [
            @format.link_to_card(@act.actor, nil, class: "_stop_propagation"),
            edited_ago,
          ]
        end
      end

      def details
        approved_actions[0..20].map do |action|
          Action::ActionRenderer.new(@format, action, action_header?,
                                     :summary).render
        end.join
      end

      def summary
        %i[create update delete draft].map do |type|
          count = count_types[type]
          next unless count.positive?
          "#{@format.action_icon type}<small> #{count if count > 1}</small>"
        end.compact.join "<small class='text-muted'> | </small>"
      end

      def act_links
        [
          link_to_history,
          (link_to_act_card unless @act_card.trash)
        ].compact.join " "
      end

      def link_to_act_card
        link_to_card @act_card, icon_tag(:new_window), class: "_stop_propagation"
      end

      def link_to_history
        link_to_card @act_card, icon_tag(:history),
                     path: { view: :history, look_in_trash: true },
                     class: "_stop_propagation",
                     rel: "nofollow"
      end

      def approved_actions
        @approved_actions ||= actions.select { |a| a.card&.ok?(:read) }
        # FIXME: should not need to test for presence of card here.
      end

      def action_header?
        true
        # @action_header ||= approved_actions.size != 1 ||
        #                   approved_actions[0].card_id != @format.card.id
      end

      def count_types
        @count_types ||=
          approved_actions.each_with_object(
            Hash.new { |h, k| h[k] = 0 }
          ) do |action, type_cnt|
            type_cnt[action.action_type] += 1
          end
      end

      def edited_ago
        return "" unless @act.acted_at

        "#{time_ago_in_words(@act.acted_at)} ago"
      end

      def collapse_id
        "act-id-#{@act.id}"
      end

      def accordion_item
        # context = @act.main_action&.draft ? :warning : :default
        @format.accordion_item header, body: details, collapse_id: collapse_id
      end

      def act_accordion_heading
        header + subtitle
      end


      # Revert:
      #   current update
      # Restore:
      #   current deletion
      # Revert and Restore:
      #   old deletions
      # blank:
      #   current create
      # save as current:
      #   not current, not deletion
      def rollback_link
        return unless @card.ok? :update

        wrap_with :div, class: "act-link collapse #{collapse_id} float-end" do
          content_tag(:small, revert_link)

          # link_to "Save as current",
          #         class: "slotter", remote: true,
          #         method: :post, rel: "nofollow",
          #         "data-slot-selector" => ".card-slot.history-view",
          #         path: { action: :update, action_ids: prior,
          #                 view: :open, look_in_trash: true }
        end
      end

      def deletion_act?
        act_type == :delete
      end

      def act_type
        @act.main_action.action_type
      end

      def show_or_hide_changes_link
        wrap_with :div, class: "act-link" do
          @format.link_to_view(
            :act, "#{@args[:hide_diff] ? 'Show' : 'Hide'} changes",
            path: { act_id: @args[:act].id, act_seq: @args[:act_seq],
                    hide_diff: !@args[:hide_diff], action_view: :expanded,
                    act_context: @args[:act_context], look_in_trash: true }
          )
        end
      end

      def autosaved_draft_link opts={}
        text = opts.delete(:text) || "autosaved draft"
        opts[:path] = { edit_draft: true }
        add_class opts, "navbar-link"
        link_to_view :edit, text, opts
      end
    end
  end
end
