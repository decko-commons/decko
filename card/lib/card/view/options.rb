class Card
  class View
    # Manages options for rendering card views
    #
    # Many options are available to sharks via nests. (See https://decko.org/Nest_Syntax)
    #
    #      {{cardname|hide:menu}}
    #
    # These options and others are available to monkeys when rendering views
    # via #render or #nest.
    #
    #      nest "cardname", hide: :menu
    #      render :viewname, hide: :menu
    #
    module Options
      # the keymap represents a 2x2 matrix, where the factors are
      # (a) whether an option's value can be set by a shark via nests, and
      # (b) whether subviews can inherit the option from a parent view.
      #
      #                  for sharks  | not for sharks
      #                 ________________________________
      #       inherit  | both        | heir
      # don't inherit  | shark       | none
      #
      # (note: each option will likely some day merit its own object)
      @keymap = {
        shark: [
          :view,           # view to render
          :nest_name,      # name as used in nest
          :nest_syntax,    # full nest syntax
          :wrap,           # wrap the nest with a wrapper
          :show,           # render these views when optional
          :hide            # do not render these views when optional
        ],                 #   show/hide can be view (Symbol), list of views (Array),
        #                      or comma separated views (String)
        # NOTE: although show and hide are in this non-inheriting group, they are
        # actually inherited, just not through the standard mechanism. Because, well,
        # they're weird. (See process_visibility)
        heir: [
          :main,           # format object is page's "main" object (Boolean)
          :home_view,      # view for slot to return to when no view specified
          :edit_structure, # use a different structure for editing (Array)
          :cql,            # contextual cql alterations for search cards (Hash)
          :action_id,      # a Card::Action id (Integer)
          :content_opts    # options for Card::Content.new
          # :context_names   # names used to contextualize titles
        ],
        both: [
          :help,           # cue text when editing
          :structure,      # overrides the content of the card
          :title,          # overrides the name of the card
          :variant,        # override the canonical version of the name with a different
                           # variant
          :input_type,     # inline_nests makes a form within standard content (Symbol)
          :type,           # set the default type of new cards
          :size,           # set an image size
                           # (also used for character limit in one_line_content)
          :params,         # parameters for add button.  deprecated!
          :items,          # options for items (Hash)
          :cache,          # change view cache behaviour
          #                    (Symbol<:always, :standard, :never>)
          :edit,           # edit mode
          #                    (Symbol<:inline, :standard, :full>)
          :separator,      # item separator in certain lists
          :filter
        ],
        none: [
          :skip_perms,     # do not check permissions for this view (Boolean)
          :main_view,      # this is main view of page (Boolean)
          :layout          #
        ]
      }
      # Note: option values are strings unless otherwise noted

      class << self
        attr_reader :keymap

        def add_option name, type
          raise "invalid option type: #{type}" unless @keymap.key?(type)

          @keymap[type] << name
          reset_key_lists
          VooApi.define_getter name
          VooApi.define_setter name
        end
      end

      extend KeyLists
      include VooApi
      include Visibility
    end
  end
end
