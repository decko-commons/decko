format :html do
  view :type, unknown: true do
    link_to_card card.type_card, nil, class: "cardtype"
  end

  def type_formgroup args={}
    if card.cards_of_type_exist?
      wrap_with :div, t(:core_cards_exist, scope: "core", cardname: safe_name)
    else
      super
    end
  end

  view :add_link do
    add_link
  end

  view :add_button do
    add_link class: "btn btn-secondary"
  end

  def add_link opts={}
    voo.title ||= t(:format_add_card, cardname: safe_name)
    link_to render_title, add_link_opts(opts)
  end

  def add_link_opts opts
    modal = opts.delete :modal
    if modal.nil? || modal
      modal_link_opts opts.merge(path: add_path(:new_in_modal))
    else
      opts.merge path: add_path(:new)
    end
  end

  view :add_url do
    card_url _render_add_path
  end

  def add_path view
    path_args = { mark: card.name }
    process_voo_params(path_args) if voo.params
    if view == :new
      path_args[:action] = :new
    else
      path_args[:action] = :type
      path_args[:view] = view
    end
    path path_args
  end

  # don't cache because it depends on update permission for another card
  view :configure_link, cache: :never, perms: :can_configure? do
    configure_link
  end

  def can_configure?
    Card.fetch(card, :type, :structure, new: {}).ok? :update
  end

  view :configure_button, cache: :never, denial: :blank, perms: :can_configure? do
    configure_link "btn btn-secondary"
  end

  def configure_link css_class=nil
    return "" unless Card.fetch(card, :type, :structure, new: {}).ok? :update

    voo.title ||= t(:format_configure_card, cardname: safe_name.pluralize)
    title = _render_title
    link_to_card card, title,
                 path: { view: :board,
                         board: { tab: :rules_tab },
                         set: Card::Name[safe_name, :type] },
                 class: css_classes("configure-type-link ms-3", css_class)
  end

  private

  def process_voo_params path_args
    context = (@parent&.card || card).name
    Rack::Utils.parse_nested_query(voo.params).each do |key, value|
      value = value.to_name.absolute(context) if value
      key = key.to_name.absolute(context)
      path_args[key] = value
    end
  end
end
