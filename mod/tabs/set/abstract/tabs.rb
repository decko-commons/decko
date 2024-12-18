include_set Abstract::BsBadge

format :html do
  view :tabs, cache: :never do
    tabs tab_map, default_tab, load: :lazy do
      _render! tab_map.dig(default_tab, :view)
    end
  end

  def tab_map
    @tab_map ||= generate_tab_map
  end

  def tab_list
    []
  end

  def tab_options
    {}
  end

  def default_tab
    tab_from_params || tab_map.keys.first
  end

  def tab_badge count, label, opts={}
    haml :tab_badge, badge_haml_opts(count, label, opts)
  end

  def tab_title label, opts
    opts ||= {}
    label = tab_badge opts[:count], label, opts if opts[:count]
    wrap_with(:div, class: "tab-title") { label }
  end

  private

  def generate_tab_map
    options = tab_options
    tab_list.each_with_object({}) do |tab_key, hash|
      hash[tab_key] = {
        view: (options.dig(tab_key, :view) || "#{tab_key}_tab"),
        title: tab_title_from_map(tab_key, options[tab_key])
      }
    end
  end

  def tab_from_params
    Env.params[:tab]&.to_sym
  end

  def tab_url tab
    path tab: tab
  end

  def tab_title_from_map tab_key, opts
    opts ||= {}
    if Codename.exist? tab_key
      tab_title_from_fieldcode tab_key, opts
    else
      label = opts[:label] || tab_key
      tab_title label, opts
    end
  end

  def tab_title_from_fieldcode fieldcode, opts={}
    field_card = card.fetch fieldcode, new: {}

    %i[label count klass].each do |part|
      opts[part] = send("tab_title_#{part}", field_card) unless opts.key? part
    end

    tab_title opts[:label], opts
  end

  def tab_title_klass field_card
    css_classes field_card.safe_set_keys
  end

  def tab_title_count field_card
    field_card.try(:cached_count) || field_card.try(:count)
  end

  def tab_title_label field_card
    field_card.name.right_name.vary :plural
  end
end
