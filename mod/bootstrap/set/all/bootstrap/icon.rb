basket[:icons] = {
  material: {
    plus: :add,
    pencil: :edit,
    trash: :delete,
    wrench: :build,
    new_window: :open_in_new,
    history: :history,
    triangle_left: :expand_less,
    triangle_right: :expand_more,
    flag: :flag,
    option_horizontal: :more_horiz,
    option_vertical: :more_vert,
    pushpin: :pin_drop,
    baby_formula: :device_hub,
    log_out: :call_made,
    log_in: :call_received,
    explore: :explore,
    remove: :close,
    expand: :expand_more,
    collapse_down: :expand_less,
    globe: :public,
    commenting: :comment
  },

  bootstrap: {
    plus: "plus-lg",
    pencil: "pencil-fill",
    trash: "trash-fill",
    wrench: :wrench,
    new_window: "box-arrow-up-right",
    history: :clock,
    triangle_left: "chevron-up",
    triangle_right: "chevron-down",
    flag: "flag-fill",
    reorder: "grip-horizontal",
  },

  font_awesome: {
    close: :times,
    check_circle: "check-circle",
    reorder: "align-justify",
    history: "clock-rotate-left",
    warning: "exclamation-circle",
    unknown: "plus-square",
    help: "question-circle",
    modal: :expand,
  },
}

format :html do
  view :icons, template: :haml

  def icon_tag icon, opts={}
    with_icon_tag_opts(opts) do |tag_opts|
      library = tag_opts.delete(:library) || default_icon_library
      universal_icon_tag icon, library, tag_opts
    end
  end

  def default_icon_library
    :material
  end

  def fa_icon icon, opts={}
    universal_icon_tag icon, :font_awesome, opts
  end

  def glyphicon_icon_tag icon, opts={}
    prepend_class opts, "glyphicon glyphicon-#{icon}"
    wrap_with :span, "", opts.merge("aria-hidden": true)
  end

  def font_awesome_icon_tag icon, opts={}
    prepend_class opts, "fa#{'b' if opts.delete :brand} fa-#{icon}"
    wrap_with :i, "", opts
  end

  def material_icon_tag icon, opts={}
    add_class opts, "material-icons"
    wrap_with :i, icon, opts
  end

  def bootstrap_icon_tag icon, opts={}
    prepend_class opts, "bi-#{icon}"
    wrap_with :i, "", opts
  end

  def universal_icon_tag icon, icon_library=default_icon_library, opts={}
    return "" unless icon.present?

    with_icon_tag_opts(opts) do |tag_opts|
      send "#{icon_library}_icon_tag", icon_lookup(icon_library, icon), tag_opts
    end
  end

  def icon_lookup library, icon
    if (found_in_library = basket[:icons][library][icon])
      found_in_library
    elsif (library != default_icon_library) &&
          (found_in_default_library = basket[:icons][default_icon_library][icon])
      found_in_default_library
    else
      icon
    end
  end

  def all_icon_keys
    basket[:icons].values.map(&:keys).flatten.uniq
  end

  private

  def with_icon_tag_opts opts={}
    opts = { class: opts } unless opts.is_a? Hash
    yield opts
  end

  def icon_collection name
    basket[:icons][name].map do |key, icon|
      icon_tag =
      "#{icon_tag} #{key}"
    end.join "<br/>"
  end
end
