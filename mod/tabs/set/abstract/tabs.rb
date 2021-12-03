include_set Abstract::BsBadge

format :html do
  view :tabs, cache: :never do
    tabs tab_map, default_tab, load: :lazy do
      _render! "#{default_tab}_tab"
    end
  end

  def tab_map
    @tab_map ||= generate_tab_map
  end

  def generate_tab_map
    options = tab_options
    tab_list.each_with_object({}) do |codename, hash|
      hash[codename] = {
        view: "#{codename}_tab",
        title: tab_title(codename, options[codename])
      }
    end
  end

  def tab_list
    []
  end

  def tab_options
    {}
  end

  def one_line_tab?
    false
  end

  def default_tab
    tab_from_params || tab_map.keys.first
  end

  def tab_from_params
    return unless Env.params[:tab]
    Env.params[:tab].to_sym
  end

  def tab_wrap
    bs_layout do
      row 12 do
        col output(yield), class: "padding-top-10"
      end
    end
  end

  def tab_url tab
    path tab: tab
  end

  def tab_title fieldcode, opts={}
    opts ||= {}
    parts = tab_title_parts fieldcode, opts
    info = tab_title_info parts[:icon], parts[:count]
    wrapped_tab_title parts[:label], info
  end

  def tab_title_info icon, count
    if count
      tab_count_badge count, icon
    else
      icon || tab_space
    end
  end

  def tab_space
    one_line_tab? ? :nil : "&nbsp;"
  end

  def tab_count_badge count, icon_tag
    klass = nil
    if count.is_a? Card
      klass = css_classes count.safe_set_keys
      count = count.try(:cached_count) || count.count
    end
    tab_badge count, icon_tag, klass: klass
  end

  def tab_title_parts fieldcode, opts
    %i[count icon label].each_with_object({}) do |part, hash|
      hash[part] = opts.key?(part) ? opts[part] : send("tab_title_#{part}", fieldcode)
    end
  end

  def tab_title_count fieldcode
    field_card = card.fetch fieldcode, new: {}
    field_card if field_card.respond_to? :count
  end

  def tab_title_icon fieldcode
    tab_icon_tag fieldcode
  end

  def tab_title_label fieldcode
    fieldcode.cardname.vary :plural
  end

  def wrapped_tab_title label, info=nil
    wrap_with :div, class: "tab-title text-center #{'one-line-tab' if one_line_tab?}" do
      [wrapped_tab_title_info(info),
       wrap_with(:span, label, class: "count-label")].compact
    end
  end

  def wrapped_tab_title_info info
    info ||= tab_space
    return unless info

    klass = css_classes "count-number", "clearfix"
    wrap_with :span, info, class: klass
  end

  # TODO: handle mapped icon tagging in decko
  def tab_icon_tag key
    try :mapped_icon_tag, key
  end
end
