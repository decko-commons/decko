class Card
  class View
    module Options
      module KeyLists
        # all standard option keys
        # @return [Array]
        def all_keys
          @all_keys ||= keymap.each_with_object([]) { |(_k, v), a| a.push(*v) }
        end

        # keys whose values can be set by Sharks in card nests
        # @return [Array]
        def shark_keys
          @shark_keys ||= ::Set.new(keymap[:both]) + keymap[:shark]
        end

        # keys that follow simple standard inheritance pattern from parent views
        # @return [Array]
        def heir_keys
          @heir_keys ||= ::Set.new(keymap[:both]) + keymap[:heir]
        end

        # Keys that can be read or written via accessors
        # @return [Array]
        def accessible_keys
          all_keys - [   # (all but the following)
            :view,       # view is accessed as requested_view or ok_view and cannot be
            # directly manipulated
            :show, :hide # these have a more extensive API (see Card::View::Visibility)
          ]
        end

        def slot_keys
          @slot_keys ||= all_keys - [:skip_perms]
        end

        def reset_key_lists
          @all_keys = nil
          @shark_keys = nil
          @heir_keys = nil
        end
      end
    end
  end
end
