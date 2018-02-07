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
      commenting: :comment,
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
      commenting: :commenting,
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
    wrap_with :span, "", opts.merge("aria-hidden" => true)
  end

  def font_awesome_icon_tag icon, opts={}
    prepend_class opts, "fa fa-#{icon_class(:font_awesome, icon)}"
    wrap_with :i, "", opts
  end

  def material_icon_tag icon, opts={}
    add_class opts, "material-icons"
    wrap_with :i, icon_class(:material, icon), opts
  end

  def button_link link_text, opts={}
    btn_type = opts.delete(:btn_type) || "primary"
    opts[:class] = [opts[:class], "btn btn-#{btn_type}"].compact.join " "
    smart_link_to link_text, opts
  end

  def dropdown_button name, items_or_opts={}, opts={}
    items = block_given? ? yield : items_or_opts
    opts = items_or_opts if block_given?
    <<-HTML
      <div class="btn-group btn-group-sm #{opts[:extra_css_class]}" role="group">
        <button class="btn btn-primary dropdown-toggle"
                data-toggle="dropdown" title="#{name}" aria-expanded="false"
                aria-haspopup="true">
          #{icon_tag opts[:icon] if opts[:icon]} #{name}
          <span class="caret"></span>
        </button>
        #{dropdown_list items, opts[:class], opts[:active]}
      </div>
    HTML
  end

  def dropdown_list items, extra_css_class=nil, active=nil
    wrap_with :ul, class: "dropdown-menu #{extra_css_class}", role: "menu" do
      case items
      when Array
        items.map.with_index { |item, i| dropdown_list_item item, i, active }
      when Hash
        items.map { |key, item| dropdown_list_item item, key, active }
      else
        [items]
      end.compact.join "\n"
    end
  end

  def dropdown_list_item item, active_test, active
    return unless item
    "<li #{'class=\'active\'' if active_test == active}>#{item}</li>"
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def split_button main_button, active_item
    wrap_with :div, class: "btn-group btn-group-sm" do
      [
        main_button,
        split_button_toggle,
        dropdown_list(yield, nil, active_item)
      ]
    end
  end

  def split_button_toggle
    button_tag(situation: "primary",
               class: "dropdown-toggle",
               "data-toggle" => "dropdown",
               "aria-haspopup" => "true",
               "aria-expanded" => "false") do
      '<span class="caret"></span><span class="sr-only">Toggle Dropdown</span>'
    end
  end

  def list_group content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content).map(&:to_s)
    add_class options, "list-group"
    options[:items] ||= {}
    add_class options[:items], "list-group-item"
    list_tag content, options
  end

  def list_tag content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content)
    default_item_options = options.delete(:items) || {}
    tag = options[:ordered] ? :ol : :ul
    wrap_with tag, options do
      content.map do |item|
        i_content, i_opts = item
        i_opts ||= default_item_options
        wrap_with :li, i_content, i_opts
      end
    end
  end
end
