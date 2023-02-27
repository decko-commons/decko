format :html do
  # same for all:
  # :search,
  ICON_MAP = {
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
    material: {
      plus: :add,
      pencil: :edit,
      trash: :delete,
      new_window: :open_in_new,
      history: :history,
      collapse: :expand_less,
      expand: :expand_more,
      flag: :flag,
      remove: :close,
      close: :close,
      board: :space_dashboard,
      warning: :warning,
      unknown: :add_box,
      help: :help,
      modal: :fullscreen,
      reorder: :reorder,
      create_action: :add_circle,
      update_action: :edit,
      delete_action: :remove_circle,
      draft: :build,
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

  def bs_icon icon, opts={}
    universal_icon_tag icon, :bootstrap, opts
  end

  def icon_tag icon, opts={}
    with_icon_tag_opts(opts) do |tag_opts|
      library = tag_opts.delete(:library) || default_icon_library
      universal_icon_tag icon, library, tag_opts
    end
  end

  def universal_icon_tag icon, icon_library=default_icon_library, opts={}
    return "" unless icon.present?

    with_icon_tag_opts(opts) do |tag_opts|
      send "#{icon_library}_icon_tag", icon, tag_opts
    end
  end

  def default_icon_library
    :material
  end

  def glyphicon_icon_tag icon, opts={}
    prepend_class opts, "glyphicon glyphicon-#{icon_class(:glyphicon, icon)}"
    wrap_with :span, "", opts.merge("aria-hidden": true)
  end

  def font_awesome_icon_tag icon, opts={}
    prepend_class opts,
                  "fa#{'b' if opts.delete :brand} fa-#{icon_class(:font_awesome, icon)}"
    wrap_with :i, "", opts
  end

  def material_icon_tag icon, opts={}
    add_class opts, "material-icons"
    wrap_with :i, icon_class(:material, icon), opts
  end

  def bootstrap_icon_tag icon, opts={}
    prepend_class opts, "bi-#{icon_class(:bootstrap, icon)}"
    wrap_with :i, "", opts
  end

  private

  def with_icon_tag_opts opts={}
    opts = { class: opts } unless opts.is_a? Hash
    yield opts
  end

  view :icons do
    ICON_MAP.keys.map do |collection|
      "<h3>#{collection}</h3>\n#{icon_collection collection}"
    end.join "<br/>"
  end

  def icon_collection name
    ICON_MAP[name].map do |key, icon|
      icon_tag = send "#{name}_icon_tag", icon
      "#{icon_tag} #{key}"
    end.join "<br/>"
  end
end
