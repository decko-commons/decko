format :html do
  # @param tab_hash [Hash] keys are the tab names
  #   Each value can be either a String or a Hash.
  #   If a Hash can contain the following keys:
  #     :title - the label to appear in the clickable tab nav.
  #        if title is not specified, the key is used
  #     :content - body of tab pane
  #     :button_attr - attributes for button link in tab nav.
  #
  #   If using lazy loading (see :load below), the following options also apply
  #     :path - explicit path to use for tab pane
  #     :view - card view from which to auto-construct path (if missing, uses key)
  #
  #   If the value is a String, it is treated as the tab content for static tabs and
  #     the view for lazy tabs
  #
  # @param active_name [String] label of the tab that should be active at the
  #
  # @param [Hash] args options
  # @option args [String] :tab_type ('tabs') use pills or tabs
  # @option args [Hash] :panel_attr html args used for the panel div
  # @option args [Hash] :pane_attr html args used for the pane div
  # @option args [Hash] :load. `:lazy` for lazy-loading tabs
  #
  # @param [Block] block content of the active tab (for lazy-loading)
  # beginning (default is the first)
  #
  # @return [HTML] bootstrap tabs element with all content preloaded
  def tabs tab_hash, active_name=nil, args={}, &block
    klass = args[:load] == :lazy ? Card::LazyTab : Card::Tab
    args.reverse_merge!(
      panel_attr: {},
      pane_attr: {},
      tab_type: "tabs",
      block: block,
      tab_objects: Card::Tab.tab_objects(self, tab_hash, active_name, klass)
    )
    haml :tab_panel, args
  end
end
