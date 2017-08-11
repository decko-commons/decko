class Card
  class Format
    module Nest

      # Renders views for a nests
      module View
        def with_nest_mode new_mode
          old_mode = nest_mode
          @nest_mode = new_mode
          result = yield
          @nest_mode = old_mode
          result
        end

        def nest_mode
          @nest_mode ||= parent ? parent.nest_mode : :normal
        end

        # private

        def modal_nest_view view
          # Note: the subformat always has the same nest_mode as its parent format
          case nest_mode
          when :edit     then view_in_edit_mode(view)
          when :template then :template_rule
          when :closed   then view_in_closed_mode(view)
          else view
          end
        end

        # Returns the view that the card should use
        # if nested in edit mode
        def view_in_edit_mode homeview
          hide_view_in_edit_mode?(homeview) ? :blank : :edit_in_form
        end

        def hide_view_in_edit_mode? view
          Card::Format.perms[view] == :none || # view never edited
            card.structure                  || # not yet nesting structures
            card.key.blank?                    # eg {{_self|type}} on new cards
        end

        # Return the view that the card should use
        # if nested in closed mode
        def view_in_closed_mode view
          closed_config = Card::Format.closed[view]
          if closed_config == true
            view
          elsif Card::Format.error_code[view]
            view
          elsif closed_config
            closed_config
          elsif !card.known?
            :closed_missing
          else
            :closed_content
          end
        end
      end
    end
  end
end
