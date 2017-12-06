include_set Abstract::ToolbarSplitButton

format :html do
  TOOLBAR_TITLE = {
    edit: "content",             edit_name: "name",      edit_type: "type",
    edit_structure: "structure", edit_nests: "nests",    history: "history",
    common_rules: "common",      recent_rules: "recent", grouped_rules: "all",
    edit_nest_rules: "nests"
  }.freeze

  def toolbar_pinned?
    (tp = Card[:toolbar_pinned]) && tp.content == "true"
  end

  view :toolbar, cache: :never do
    tool_navbar do
      [
        # expanded_close_link,
        toolbar_split_buttons,
        # collapsed_close_link,
        # toolbar_simple_buttons,
        toolbar_right_buttons
      ]
    end
  end

  def default_toolbar_args args
    if params[:related]
      @related_card, _opts = related_card_and_options args.clone
    end
    @rule_view = params[:rule_view]
  end

  # def default_toolbar_args args
  #   args[:nested_fields] = nested_fields
  #   args[:active_toolbar_button] ||= active_toolbar_button @slot_view, args
  # end

  def expanded_close_link
    opts = {}
    opts[:no_nav] = true
    close_link "navbar-text"
  end

  def collapsed_close_link
    opts = {}
    opts[:no_nav] = true
    close_link "float-right d-sm-none navbar-text", opts
  end

  def tool_navbar
    navbar "toolbar-#{card.name.safe_key}-#{voo.home_view}",
           toggle_align: :left, class: "slotter toolbar",
           navbar_type: "dark",
           no_collapse: true do
      yield
    end
  end

  def toolbar_split_buttons
    wrap_with :form do
      [
        account_split_button,
        toolbar_button_card(:activity),
        toolbar_button_card(:rules),
        edit_split_button
      ]
    end
  end

  def toolbar_simple_buttons
    _render :toolbar_buttons
  end

  def toolbar_right_buttons
    wrap_with :div do
      [
        toolbar_simple_buttons,
        expanded_close_link
      ]
    end
  end

  # TODO: decentralize and let views choose which menu they are in.
  # (Also, should only be represented once.  Currently we must configure
  # this relationship twice)
  def active_toolbar_button
    @active_toolbar_button ||=
      case voo.root.ok_view
      when :follow, :editors, :history    then "activity"
      when :edit_rules, :edit_nest_rules  then "rules"
      when :edit, :edit_name, :edit_type,
        :edit_structure, :edit_nests   then "edit"
      when :related                       then active_related_toolbar_button
      end
  end

  def active_related_toolbar_button
    return unless (codename = related_codename @related_card)
    case codename
    when :discussion, :editors                        then "activity"
    when :account, :roles, :edited, :created, :follow then "account"
    when :structure                                   then "edit"
    else                                                   "rules"
    end
  end

  def active_toolbar_item
    @active_toolbar_item ||=
      case
      when @rule_view                   then @rule_view.to_sym
      when voo.root.ok_view != :related then voo.root.ok_view
      when @related_card                then related_codename @related_card
      end
  end

  def toolbar_view_title view
    if view == :edit_rules
      current_set_card.name
    else
      TOOLBAR_TITLE[view]
    end
  end

  def edit_split_button
    toolbar_split_button "edit", view: :edit, icon: :edit do
      {
        edit:       _render_edit_link,
        edit_nests: (_render_edit_nests_link if nests_editable?),
        structure:  (_render_edit_structure_link if structure_editable?),
        edit_name:  _render_edit_name_link,
        edit_type:  _render_edit_type_link
      }
    end
  end

  def nests_editable?
    !card.structure && nested_fields.present?
  end

  def account_split_button
    return "" unless card.accountable?
    toolbar_split_button "account", related: :account, icon: :account_box do
      %i[account roles created edited follow].each_with_object({}) do |item, hash|
        label = item == :account ? tr(:details) : tr(item)
        args = { class: "dropdown-item" }
        args[:path] = { related: { view: :edit } } if item == :account
        hash[item] = link_to_related item, label, args
      end
    end
  end

  def toolbar_button_card name
    button_codename = "#{name}_toolbar_button".to_sym
    return "" unless (button_card = Card[button_codename])
    with_nest_mode :normal do
      nest button_card, view: :core
    end
  end

  def related_codename related_card
    return nil unless related_card
    Card.quick_fetch(related_card.name.right)&.codename
  end

  def close_link extra_class, opts={}
    nav_css_classes = css_classes("nav navbar-nav", extra_class)
    css_classes = opts[:no_nav] ? extra_class : nav_css_classes
    wrap_with :div, class: css_classes do
      [
        # toolbar_pin_button,
        link_to_view(voo.home_view || :open, icon_tag(:remove),
                     title: "cancel",
                     class: "btn-toolbar-control toolbar-close pl-1")
      ]
    end
  end

  def toolbar_pin_button
    button_tag icon_tag(:pushpin).html_safe,
               situation: :primary, remote: true,
               title: "#{'un' if toolbar_pinned?}pin",
               class: "btn-toolbar-control toolbar-pin d-none d-sm-inline " \
                      "#{'in' unless toolbar_pinned?}active"
  end

  view :toolbar_buttons, cache: :never do
    wrap_with(:div, class: "btn-group btn-group-sm") do
      [
        _render(:delete_button,
                optional: (card.ok?(:delete) ? :show : :hide)),
        _render(:refresh_button),
        _render(:related_button)
      ]
    end
  end

  view :related_button do
    dropdown_button "", icon: :explore, class: "related",
                        extra_css_class: "d-none d-md-inline" do
      [
        ["children",       :baby_formula, "*children"],
        # ["mates",          "bed",          "*mates"],
        # FIXME: optimize and restore
        ["references out", :log_out,      "*refers_to"],
        ["references in",  :log_in,       "*referred_to_by"]
      ].map do |title, icon, tag|
        menu_item " #{title}", icon, related: tag,
                                     path: { slot: { show: :toolbar, hide: :menu } }
      end
    end
  end

  view :refresh_button do |_args|
    icon = main? ? "refresh" : "open_in_new"
    button_args = { card: card,  path: { slot: { show: :toolbar } } }
    button_args[:class] = "d-none d-sm-inline" if card.accountable?
    toolbar_button "refresh", icon, button_args
  end

  view :delete_button do |_args|
    confirm = "Are you sure you want to delete #{card.name}?"
    success = main? ? "REDIRECT: *previous" : "TEXT: #{card.name} deleted"
    toolbar_button "delete", :trash,
                   path: { action: :delete, success: success },
                   class: "slotter", remote: true, 'data-confirm': confirm
  end

  def toolbar_button text, symbol, opts={}
    link_text = toolbar_button_text text, symbol, opts.delete(:hide)
    opts[:class] = [opts[:class], "btn btn-primary"].compact * " "
    opts[:title] ||= text
    smart_link_to link_text, opts
  end

  def toolbar_button_text text, symbol, hide
    hide ||= "d-none"
    css_classes = "menu-item-label #{hide}"
    rich_text = wrap_with :span, text.html_safe, class: css_classes
    icon_tag(symbol) + rich_text
  end

  def autosaved_draft_link opts={}
    text = opts.delete(:text) || "autosaved draft"
    opts[:path] = { edit_draft: true, slot: { show: :toolbar } }
    add_class opts, "navbar-link slotter"
    link_to_view :edit, text, opts
  end

  {
    edit:           "content",
    edit_name:      "name",
    edit_type:      "type",
    edit_nests:     "nests",
    edit_structure: "structure",
    history:        "history"
  }.each do |viewname, viewtitle|

    view "#{viewname}_link" do
      voo.title ||= viewtitle
      link_to_view viewname, voo.title, class: "dropdown-item"
    end
  end

  def recently_edited_settings?
    (rs = Card[:recent_settings]) && rs.item_names.present?
  end
end
