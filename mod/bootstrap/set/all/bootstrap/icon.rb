basket[:icons] = {
  material: {
    plus: :add,
    pencil: :edit,
    trash: :delete,
    full_page: :open_in_full,
    new_window: :close_fullscreen,
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
    next: :arrow_forward_ios,
    previous: :arrow_back_ios,
    forward: :arrow_forward,
    back: :arrow_back,
    list: :list,
    search: :search,
    filter: :filter_alt,
    quick_filter: :bolt,
    reset: :restart_alt,
    more: :more_horiz,
    menu: :more_vert,
    bar_menu: :more_horiz,
    eye_open: :visibility,
    eye_slash: :visibility_off
  },
  #
  font_awesome: {
    plus: :plus,
    pencil: :pencil,
    trash: :trash,
    new_window: "external-link-square-alt",
    close: :times,
    remove: :times,
    board: "table-columns",
    reorder: "align-justify",
    history: :clock,
    warning: "exclamation-circle",
    unknown: "plus-square",
    help: "question-circle",
    modal: :expand,
    next: "arrow-right",
    previous: "arrow-left",
    create_action: "circle-plus",
    update_action: :edit,
    delete_action: "circle-minus",
    flag: :flag,
    collapse: "chevron-up",
    expand: "chevron-down",
    list: :list,
    search: "magnifying-glass",
    draft: :wrench,
    filter: :filter,
    reset: "sync-alt",
    quick_filter: :bolt
  },
  #
  bootstrap: {
    plus: "plus-lg",
    pencil: "pencil-fill",
    trash: "trash-fill",
    new_window: "box-arrow-up-right",
    history: :clock,
    collapse: "chevron-up",
    expand: "chevron-down",
    flag: "flag-fill",
    reorder: "grip-horizontal"
  }
}

format :html do
  view :icons, template: :haml

  def icon_tag icon_key, opts={}
    return "" unless icon_key.present?

    library, icon = icon_lookup icon_key
    with_icon_tag_opts(opts) do |tag_opts|
      universal_icon_tag library, icon, tag_opts
    end
  end

  def icon_libraries
    @icon_libraries ||= Cardio.config.icon_libraries
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

  def universal_icon_tag library, icon, opts={}
    with_icon_tag_opts(opts) do |tag_opts|
      send "#{library}_icon_tag", icon, tag_opts
    end
  end

  def all_icon_keys
    basket[:icons].values.map(&:keys).flatten.uniq
  end

  private

  def icon_lookup icon
    icon = icon.to_sym

    icon_libraries.each do |library|
      found_icon = basket[:icons][library][icon]
      return [library, found_icon] if found_icon
    end

    [icon_libraries.last, icon]
  end

  def with_icon_tag_opts opts={}
    opts = { class: opts } unless opts.is_a? Hash
    yield opts
  end
end
