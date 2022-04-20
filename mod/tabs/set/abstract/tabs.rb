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

  def tab_url tab
    path tab: tab
  end

  def tab_title fieldcode, opts={}
    opts ||= {}
    parts = tab_title_parts fieldcode, opts
    info = tab_count_badge parts[:count]
    wrapped_tab_title parts[:label], info
  end


  def tab_count_badge count
    klass = nil
    if count.is_a? Card
      klass = css_classes count.safe_set_keys
      count = count.try(:cached_count) || count.count
    end

    tab_badge(count, "", klass: klass) if count
  end

  def tab_title_parts fieldcode, opts
    # %i[count icon label]
    %i[label count].each_with_object({}) do |part, hash|
      hash[part] = opts.key?(part) ? opts[part] : send("tab_title_#{part}", fieldcode)
    end
  end

  def tab_title_count fieldcode
    field_card = card.fetch fieldcode, new: {}
    field_card if field_card.respond_to? :count
  end

  def tab_title_label fieldcode
    fieldcode.cardname.vary :plural
  end

  def wrapped_tab_title label, info=nil
    wrap_with :div, class: "tab-title text-center" do
      [wrap_with(:span, label, class: "count-label"), info].compact
    end
  end


  # def tab_title_icon fieldcode
  #   tab_icon_tag fieldcode
  # end
  #
  # # TODO: handle mapped icon tagging in decko
  # def tab_icon_tag key
  #   try :mapped_icon_tag, key
  # end
end
