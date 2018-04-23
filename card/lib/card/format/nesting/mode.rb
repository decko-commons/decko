class Card
  class Format
    module Nest
      module Mode
        # A nest can be rendered in one of four modes: normal, closed, edit, or template.

        # In _normal_ mode nests are rendered in the requested view without alteration.
        # In _closed_ mode nest rendering is altered to fit within a single line
        # In _edit_ mode, a nest's view is replaced (where applicable) with a form element to edit content
        # In _template_ mode, the view is replaced with a link to a nest editor to edit rules and options for that nest

        # current nest mode
        # @return [Symbol] :normal, :closed, :edit, or :template
        def nest_mode
          @nest_mode ||= parent ? parent.nest_mode : :normal
        end

        # run block with new_mode as nest_mode, then return to prior mode
        # @param new_mode [Symbol] :normal, :closed, :edit, or :template
        # @return block result
        def with_nest_mode new_mode, &block
          if new_mode
            with_altered_nest_mode new_mode, &block
          else
            yield
          end
        end

        def with_altered_nest_mode new_mode
          old_mode = nest_mode
          @nest_mode = new_mode
          yield
        ensure
          @nest_mode = old_mode
        end

        # view to be rendered in current mode
        # @param view [Symbol]
        # @return [Symbol] viewname
        def modal_nest_view view
          # Note: the subformat always has the same nest_mode as its parent format
          case nest_mode
          when :edit     then view_in_edit_mode(view)
          when :template then :template_rule
          when :closed   then view_in_closed_mode(view)
          else view
          end
        end

        # Returns the view that the card should use when nested in edit mode
        # @param view [Symbol]
        # @return [Symbol] viewname
        def view_in_edit_mode view
          hide_view_in_edit_mode?(view) ? :blank : :edit_in_form
        end

        # @param view [Symbol]
        # @return [True/False]
        def hide_view_in_edit_mode? view
          Card::Format.perms[view] == :none || # view never edited
            card.structure                  || # not yet nesting structures
            card.key.blank?                    # eg {{_self|type}} on new cards
        end

        # the view that should be used when nested in closed mode
        # @param view [Symbol]
        # @return [Symbol] viewname
        def view_in_closed_mode view
          configured_view_in_closed_mode(view) || (card.known? ? :closed_content : :closed_missing)
        end

        # the view configured in view definition for use when nested in closed mode
        # @param view [Symbol]
        # @return [Symbol] viewname
        def configured_view_in_closed_mode view
          closed_config = Card::Format.closed[view]
          return view if closed_config == true || Card::Format.error_code[view]
          closed_config
        end
      end
    end
  end
end
