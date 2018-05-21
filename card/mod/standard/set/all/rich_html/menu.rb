format :html do
  mattr_accessor :menu_items
  self.menu_items = %i[edit discuss follow page rules account more]

  view :menu, denial: :blank, tags: :unknown_ok do
    return "" if card.unknown?
    wrap_menu do
      [
        _render(:horizontal_menu, optional: :hide),
        _render_menu_link,
        modal_slot(card.name.safe_key)
      ]
    end
  end

  def wrap_menu
    wrap_with :div, class: classy(%w(menu-slot nodblclick)) do
      yield
    end
  end

  view :menu_link do
    css_class =
      show_view?(:horizontal_menu, :hide) ? "d-sm-none" : "_show-on-hover"

    wrap_with :div, class: "vertical-card-menu card-menu #{css_class}" do
      wrap_with :div, class: "btn-group slotter card-slot float-right" do
        link_to_view :vertical_menu, menu_icon, path: menu_link_path_opts
      end
    end
  end

  # this should probably be added in javascript.
  # the menu link is not a "slotter", because it doesn't replace the whole
  # slot (it just adds a menu). But it should use the js code that adds slot
  # information to urls
  def menu_link_path_opts
    opts = { slot: { home_view: voo.home_view } }
    opts[:is_main] = true if main?
    opts
  end

  def menu_icon
    material_icon "settings"
  end

  view :vertical_menu, cache: :never, tags: :unknown_ok do
    wrap_with :ul, class: "btn-group float-right slotter" do
      [vertical_menu_toggle, vertical_menu_item_list]
    end
  end

  def vertical_menu_toggle
    wrap_with :span, "<a href='#'>#{menu_icon}</a>",
              class: "open-menu dropdown-toggle",
              "data-toggle" => "dropdown",
              "aria-expanded" => "false"
  end

  def vertical_menu_item_list
    wrap_with :ul, class: "dropdown-menu dropdown-menu-right", role: "menu" do
      menu_item_list.map do |item|
        %{<li>#{item}</li>}
      end.join("\n").html_safe
    end
  end

  view :horizontal_menu, cache: :never do
    wrap_with :div, class: "btn-group btn-group-sm slotter float-right card-menu "\
                             "horizontal-card-menu d-none d-sm-inline-flex" do
      menu_item_list(class: "btn btn-outline-secondary").join("\n").html_safe
    end
  end

  def menu_item_list link_opts={}
    menu_items.map do |item|
      next unless show_menu_item?(item)
      send "menu_item_#{item}", link_opts
    end.compact
  end

  menu_items.each do |item|
    view "menu_item_#{item}" do
      send "menu_item_#{item}", {}
    end
  end

  def menu_item_edit opts
    menu_item "edit", "edit", opts.merge(view: :edit)
  end

  def menu_item_discuss opts
    menu_item "discuss", "comment",
              opts.merge(related: :discussion.cardname.key)
  end

  def menu_item_follow opts
    add_class opts, "dropdown-item"
    follow_link opts, true
  end

  def menu_item_page opts
    menu_item "page", "open_in_new", opts.merge(card: card)
  end

  def menu_item_rules opts
    menu_item "rules", "build", opts.merge(view: :edit_rules)
  end

  def menu_item_account opts
    menu_item "account", "person", opts.merge(
      view: :related,
      path: { slot: { items: { nest_name: "+#{:account.cardname.key}", view: :edit } } }
    )
  end

  def menu_item_more opts
    view = voo.home_view || :open
    menu_item "", :option_horizontal, opts.merge(
      view: view, path: { slot: { show: :toolbar } }
    )
  end

  def menu_item text, icon, opts={}
    link_text = "#{material_icon(icon)}<span class='menu-item-label'>#{text}</span>"
    add_class opts, "dropdown-item"
    smart_link_to link_text.html_safe, opts
  end

  def show_menu_item? item
    voo&.show?("menu_item_#{item}") && send("show_menu_item_#{item}?")
  end

  def show_menu_item_discuss?
    discussion_card = menu_discussion_card
    return unless discussion_card
    permission_task = discussion_card.new_card? ? :comment : :read
    discussion_card.ok? permission_task
  end

  def show_menu_item_page?
    card.name.present? && !main?
  end

  def show_menu_item_rules?
    card.virtual?
  end

  def show_menu_item_edit?
    return unless card.real?
    card.ok?(:update) || structure_editable?
  end

  def show_menu_item_account?
    return unless card.real?
    card.account && card.ok?(:update)
  end

  def show_menu_item_follow?
    return unless card.real?
    show_follow?
  end

  def show_menu_item_more?
    card.real?
  end

  def menu_discussion_card
    return if card.new_card?
    return if discussion_card?
    card.fetch trait: :discussion, skip_modules: true, new: {}
  end

  def discussion_card?
    card.junction? && card.name.tag_name.key == :discussion.cardname.key
  end
end
