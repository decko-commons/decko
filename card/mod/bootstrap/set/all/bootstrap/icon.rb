format :html do
  # same for all:
  # :search,
  ICON_MAP = {
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
      check_circle_o: nil,
      commenting: :comment
    },
    font_awesome: {
      option_horizontal: :ellipsis_h,
      pushpin: "thumb-tack",
      globe: :globe,
      zoom_out: "search-minus",
      close: :remove,
      check_circle_o: "check-circle-o",
      check_circe: "check-circle",
      reorder: "align-justify",
      commenting: :commenting
    },
    glyphicon: {
      option_horizontal: "option-horizontal",
      option_vertical: "option-vertical",
      triangle_left: "triangle-left",
      triangle_right: "triagnle-right",
      baby_formula: "baby-formula",
      log_out: "log-out",
      log_in: "log-in",
      collapse_down: "collaps-down",
      globe: :globe,
      zoom_out: "zoom-out",
      close: :remove,
      new_window: "new-window",
      history: :time,
      check_circle_o: "ok-circle",
      check_circle: "ok-sign",
      reorder: "align-justify"
    }

  }.freeze

  def icon_class library, icon
    ICON_MAP[library][icon] || icon
  end

  def material_icon icon, opts={}
    universal_icon_tag icon, :material, opts
  end

  def glyphicon icon, opts={}
    universal_icon_tag icon, :glyphicon, opts
  end

  def fa_icon icon, opts={}
    universal_icon_tag icon, :font_awesome, opts
  end

  def icon_tag icon, opts={}
    opts = { class: opts } unless opts.is_a? Hash
    library = opts.delete(:library) || default_icon_library
    universal_icon_tag icon, library, opts
  end

  def universal_icon_tag icon, icon_library=default_icon_library, opts={}
    return "" unless icon.present?

    opts = { class: opts } unless opts.is_a? Hash
    icon_method = "#{icon_library}_icon_tag"
    send icon_method, icon, opts
  end

  def default_icon_library
    :material
  end

  def glyphicon_icon_tag icon, opts={}
    prepend_class opts, "glyphicon glyphicon-#{icon_class(:glyphicon, icon)}"
    wrap_with :span, "", opts.merge("aria-hidden": true)
  end

  def font_awesome_icon_tag icon, opts={}
    prepend_class opts, "fa fa-#{icon_class(:font_awesome, icon)}"
    wrap_with :i, "", opts
  end

  def material_icon_tag icon, opts={}
    add_class opts, "material-icons"
    wrap_with :i, icon_class(:material, icon), opts
  end
end
