class Card
  class View
    # Manages options for card views, including those used in nest syntax
    module Options
      # the keymap represents a 2x2 matrix, where the factors are
      # (a) whether an option's value can be set by a Carditect via nests, and
      # (b) whether nested views can inherit the option from a parent view.
      #
      #                  for rulers  | not for rulers
      #                 ________________________________
      #       inherit  | both        | heir
      # don't inherit  | ruler       | none
      #
      # (note: each option will likely some day merit its own object)
      @keymap = {
        ruler: [
          :view,           # view to render
          :nest_name,      # name as used in nest
          :nest_syntax,    # full nest syntax
          :show,           # render these views when optional
          :hide            # do not render these views when optional
        ],                 #   show/hide can be view (Symbol), list of views (Array),
                           #   or comma separated views (String)
        # NOTE: although show and hide are in this non-inheriting group, they are
        # actually inherited, just not through the standard mechanism. Because, well,
        # they're weird. (See process_visibility options)
        heir: [
          :main,           # format object is page's "main" object (Boolean)
          :home_view,      # view for slot to return to when no view specified
          :edit_structure, # use a different structure for editing (Array)
          :wql,            # contextual wql alterations for search cards (Hash)
          :action_id,      # a Card::Action id (Integer)
          :content_opts    # options for Card::Content.new
          # :context_names   # names used to contextualize titles
        ],
        both: [
          :help,           # cue text when editing
          :structure,      # overrides the content of the card
          :title,          # overrides the name of the card
          :variant,        # override the canonical version of the name with a different variant
          :editor,         # inline_nests makes a form within standard content (Symbol)
          :type,           # set the default type of new cards
          :size,           # set an image size
          :params,         # parameters for add button.  deprecated!
          :items,          # options for items (Hash)
          :cache           # change view cache behaviour
        ],                 #   (Symbol<:always, :standard, :never>)
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
          raise "invalid option type" unless @keymap.key?(type)
          @keymap[type] << name
          reset_key_lists
        end
      end

      extend KeyLists
      include VooApi
    end
  end
end
