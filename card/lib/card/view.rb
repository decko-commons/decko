class Card
  # Card::View manages {Options view options}, {Cache view caching}, and
  # {Permission view permissions}.
  #
  # View objects, which are instantiated whenever a view is rendered, are available as
  # in views and other format methods.  The view objects can be accessed using `#voo`.
  # We sometimes feebly pretend VOO is an acronym for "view option object," but really
  # we just needed a way not to confuse these Card::View options with the countless
  # references to viewnames that naturally arise when rendering views within views within
  # views.
  #
  # When view A renders view B within the same format object, A's voo is the parent of
  # B's voo. When card C nests card D, a new (sub)format object is initialized. C is then
  # the parent _format_ of D, but D has its own root voo.
  #
  # So a lineage might look something like this:
  #
  # `F1V1 -> F1V2 -> F1V3 -> F2V1 -> F2V2 -> F3V1 ...`
  #
  #
  class View
    include Options
    include View::Cache
    include Classy
    include Permission

    extend View::Cache::ClassMethods

    attr_reader :format, :parent, :card

    class << self
      # @return [Symbol] viewname as Symbol
      def normalize view
        view.present? ? view.to_sym : nil
      end

      # @return [Array] list of viewnames as Symbols
      def normalize_list val
        case val
        when NilClass then []
        when Array    then val
        when String   then val.split(/[\s,]+/)
        when Symbol   then [val]
        else raise Card::Error, "bad show/hide argument: #{val}"
        end
      end
    end

    # @param format [Card::Format]
    # @param view [Symbol] viewname. Note: Card::View is initialized without a view
    #   when `voo` is called outside of a render,
    #   eg `subformat(cardname).method_with_voo_reference`.
    # @param raw_options [Hash]
    # @param parent [Card::View] (optional)
    def initialize format, view, raw_options={}, parent=nil
      @format = format
      @raw_view = view
      @raw_options = raw_options
      @parent = parent

      @card = @format.card
      normalize_options
    end

    # handle rendering, including optional visibility, permissions, and caching
    # @return [rendered view or a stub]
    def process
      return if process_live_options == :hide

      fetch { yield ok_view }
    end

    # the view to "attempt".  Typically the same as @raw_view, but @raw_view can
    # be overridden, eg for the main view (top view of the main card on a page)
    # @return [Symbol] view name
    def requested_view
      @requested_view ||= View.normalize live_options[:view]
    end

    # the final view.  can be different from @requested_view when there are
    # issues with permissions, recursions, unknown cards, etc.
    # @return [Symbol] view name
    def ok_view
      @ok_view ||= format.monitor_depth { altered_view || requested_view }
    end

    # @return [Card::View]
    def root
      @root = parent ? parent.root : self
    end

    # @return [true/false]
    def root?
      !parent
    end

    # the root voo of the root format
    def deep_root
      format.root.voo
    end

    # neither view nor format has a parent
    # @return [true/false]
    def deep_root?
      !parent && !format.parent
    end

    # next voo object found tracing ancestry through parent voos and/or parent formats
    # @return [Card::View]
    def next_ancestor across_format=true
      parent || (across_format && next_format_ancestor) || nil
    end

    # voo object of format's parent
    def next_format_ancestor
      format.parent&.voo
    end
  end
end
