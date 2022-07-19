format :html do
  def button_link link_text, opts={}
    btn_type = opts.delete(:btn_type) || "primary"
    opts[:class] = [opts[:class], "btn btn-#{btn_type}"].compact.join " "
    smart_link_to link_text, opts
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def list_group content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content).map(&:to_s)
    add_list_group_classes options
    list_tag content, options
  end

  def list_tag content_or_options=nil, options={}, &block
    content, options = list_tag_content_and_options content_or_options, options, &block
    default_item_options = options.delete(:items) || {}
    wrap_with (options[:ordered] ? :ol : :ul), options do
      list_item_tags content, default_item_options
    end
  end

  def list_item_tags content, default_item_options
    content.map do |item|
      i_content, i_opts = item
      i_opts ||= default_item_options
      wrap_with :li, i_content, i_opts
    end
  end

  def badge_tag content, options={}
    add_class options, "badge"
    wrap_with :span, content, options
  end

  def popover_link text, title=nil, link_text=nil, opts={}
    link_text ||= fa_icon "question-circle"
    link_to link_text, popover_opts(text, title, opts)
  end

  def popover_opts text, title, opts
    add_class opts, "ps-1 _popover_link"
    text = "&nbsp;" unless text.present?
    opts.reverse_merge! path: "#",
                        tabindex: 0,
                        data: { "bs-toggle": "popover",
                                "bs-trigger": "hover focus",
                                # "bs-container": ".modal.show",
                                "bs-content": text }
    opts["data-bs-title"] = title if title
    opts
  end

  private

  def list_tag_content_and_options content_or_options, options
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    [Array(content), options]
  end

  def add_list_group_classes options
    add_class options, "list-group"
    options[:items] ||= {}
    add_class options[:items], "list-group-item"
  end
end
