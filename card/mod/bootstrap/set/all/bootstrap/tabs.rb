# TODO: this should really be much more object oriented.  We need a Tab class.

format :html do
  # @param tab_type [String] 'tabs' or 'pills'
  # @param tabs [Hash] keys are the labels, values the content for the tabs
  # @param active_name [String] label of the tab that should be active at the
  # @param [Hash] args options
  # @option args [String] :tab_type ('tabs') use pills or tabs
  # @option args [Hash] :panel_args html args used for the panel div
  # @option args [Hash] :pane_args html args used for the pane div
  # beginning (default is the first)
  # @return [HTML] bootstrap tabs element with all content preloaded
  def static_tabs tabs, active_name=nil, args={}
    tab_panel tab_objects(Card::Tab, tabs, active_name), args
  end


  # @param [Hash] tabs keys are the views, values the title unless you pass a
  #   hash as value
  # @option tabs [String] :title
  # @option tabs [path] :path
  # @option tabs [Symbol] :view
  # @option tabs [HTML] :html if present use value as inner html for li tag and
  #   ignore the other tab options
  # @param [String] active_name key of the tab that should be active at the
  # beginning
  # @param [Hash] args options
  # @option args [String] :tab_type ('tabs') use pills or tabs
  # @option args [Hash] :panel_args html args used for the panel div
  # @option args [Hash] :pane_args html args used for the pane div
  # @param [Block] block content of the active tab
  # @return [HTML] bootstrap tabs element with content only for the active
  # tab; other tabs get loaded via ajax when selected
  def lazy_loading_tabs tabs, active_name, args={}, &block
    tab_panel tab_objects(Card::LazyTab, tabs, active_name), args, &block
  end

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
