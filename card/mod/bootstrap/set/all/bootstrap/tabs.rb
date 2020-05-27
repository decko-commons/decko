format :html do
  # @param tab_type [String] 'tabs' or 'pills'
  # @param tab_hash [Hash] keys are the labels, values the content for the tabs
  # @param active_name [String] label of the tab that should be active at the
  # @param [Hash] args options
  # @option args [String] :tab_type ('tabs') use pills or tabs
  # @option args [Hash] :panel_args html args used for the panel div
  # @option args [Hash] :pane_args html args used for the pane div
  # @option args [Hash] :load. `:lazy` for lazy-loading tabs
  # @param [Block] block content of the active tab (for lazy-loading)
  # beginning (default is the first)
  # @return [HTML] bootstrap tabs element with all content preloaded
  def tabs tab_hash, active_name=nil, args={}, &block
    klass = args[:load] == :lazy ? Card::LazyTab : Card::Tab
    tab_panel tab_objects(klass, tab_hash, active_name), args, &block
  end

  private

  def tab_objects klass, tab_hash, active_name
    active_name ||= tab_hash.keys.first
    tab_hash.map do |name, config|
      klass.new self, name, active_name, config
    end
  end

  def tab_panel tab_objects, args={}, &block
    haml :tab_panel, args.reverse_merge(
      panel_args: {},
      pane_args: {},
      tab_type: "tabs",
      block: block,
      tab_objects: tab_objects
    )
  end
end
