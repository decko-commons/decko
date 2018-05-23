

format :html do
  # @param tab_type [String] 'tabs' or 'pills'
  # @param tabs [Hash] keys are the labels, values the content for the tabs
  # @param active_name [String] label of the tab that should be active at the
  # beginning (default is the first)
  # @return [HTML] bootstrap tabs element with all content preloaded
  def static_tabs tabs, active_name=nil, tab_type="tabs", args={}
    tab_buttons = ""
    tab_panes = ""
    tabs.each do |tab_name, tab_content|
      active_name ||= tab_name
      active_tab = (tab_name == active_name)
      id = "#{card.name.safe_key}-#{tab_name.to_name.safe_key}"
      tab_content, button_attr =
        if tab_content.is_a?(Hash)
          [tab_content[:content], tab_content[:button_attr]]
        else
          [tab_content, {}]
        end
      tab_buttons += tab_button("##{id}", tab_name, active_tab, button_attr)
      tab_panes += tab_pane(id, tab_content, active_tab, args[:pane])
    end
    tab_panel tab_buttons, tab_panes, tab_type
  end

  # @param [Hash] tabs keys are the views, values the title unless you pass a
  #   hash as value
  # @option tabs [String] :title
  # @option tabs [path] :path
  # @option tabs [Symbol] :view
  # @option tabs [HTML] :html if present use value as inner html for li tag and
  #   ignore the other tab options
  # @param [String] active_name label of the tab that should be active at the
  # beginning
  # @param [String] active_content content of the active tab
  #   can also be passed via a block
  # @param [Hash] args options
  # @option args [String] :type ('tabs') use pills or tabs
  # @option args [Hash] :panel_args html args used for the panel div
  # @option args [Hash] :pane_args html args used for the pane div
  # @return [HTML] bootstrap tabs element with content only for the active
  # tab; other tabs get loaded via ajax when selected
  def lazy_loading_tabs tabs, active_name, active_content="", args={}, &block
    tab_buttons = ""
    tab_panes = ""
    standardize_tabs(tabs, active_name) do |tab_name, url, id, active_tab|
      tab_buttons += lazy_tab_button tab_name, id, url, active_tab
      tab_panes += lazy_tab_pane id, active_tab, active_content,
                                 args[:pane_args], &block
    end
    tab_type = args.delete(:type) || "tabs"
    tab_panel tab_buttons, tab_panes, tab_type, args[:panel_args]
  end

  def lazy_tab_button tab_name, id, url, active_tab
    return wrap_with(:li, tab_name, role: "presentation") unless url
    tab_button(
      "##{id}", tab_name, active_tab,
      "data-url" => url.html_safe,
      class: (active_tab ? nil : "load")
    )
  end

  def lazy_tab_pane id, active_tab, active_content, args
    tab_content =
      if active_tab
        block_given? ? yield : active_content
      else
        ""
      end
    tab_pane(id, tab_content, active_tab, args)
  end

  def standardize_tabs tabs, active_name
    tabs.each do |tab_view_name, tab_details|
      tab_title, url = tab_title_and_url(tab_details, tab_view_name)
      id = "#{card.name.safe_key}-#{tab_view_name.to_name.safe_key}"
      active_tab = (active_name == tab_view_name)
      yield tab_title, url, id, active_tab
    end
  end

  def tab_title_and_url tab_details, tab_view_name
    if tab_details.is_a? Hash
      tab_details[:html] ||
        [tab_details[:title], tab_details[:path] || path(tab_details[:view])]
    else
      [tab_details, path(view: tab_view_name)]
    end
  end

  def tab_panel tab_buttons, tab_panes, tab_type="tabs", args=nil
    args ||= {}
    add_class args, "tabbable"
    args.reverse_merge! role: "tabpanel"
    wrap_with :div, args do
      [
        wrap_with(:ul, tab_buttons, class: "nav nav-#{tab_type}",
                                    role: "tablist"),
        wrap_with(:div, tab_panes, class: "tab-content")
      ]
    end
  end

  def tab_button target, text, active=false, link_attr={}
    add_class link_attr, "active" if active
    link = tab_button_link target, text, link_attr
    li_args = { role: :presentation, class: "nav-item" }
    wrap_with :li, link, li_args
  end

  def tab_button_link target, text, link_attr={}
    add_class link_attr, "nav-link"
    link_to text, link_attr.merge(
      path: target, role: "tab", "data-toggle" => "tab"
    )
  end

  def tab_pane id, content, active=false, args=nil
    pane_args = { role: :tabpanel, id: id }
    pane_args.merge! args if args.present?
    add_class pane_args, "tab-pane"
    add_class pane_args, "active" if active
    wrap_with :div, content, pane_args
  end
end
