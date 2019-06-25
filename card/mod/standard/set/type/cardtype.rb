include_set Abstract::WqlSearch

def wql_content
  { type_id: id, sort: :name }
end

format :html do
  view :type do
    link_args = { class: "cardtype" }
    add_class link_args, "no-edit" if card.cards_of_type_exist?
    link_to_card card.type_card, nil, link_args
  end

  view :type_formgroup do
    if card.cards_of_type_exist?
      wrap_with :div, tr(:cards_exist, cardname: safe_name)
    else
      super()
    end
  end

  view :add_link do
    add_link
  end

  view :add_button do
    add_link "btn btn-outline-secondary"
  end

  def add_link css_class=nil
    voo.title ||= tr(:add_card, cardname: safe_name)
    title = _render_title
    link_to title, path: _render_add_path, class: css_class
  end

  view :add_url do
    card_url _render_add_path
  end

  view :add_path do
    path_args = {}
    if voo.params
      context = ((@parent&.card) || card).name
      Rack::Utils.parse_nested_query(voo.params).each do |key, value|
        value = value.to_name.absolute(context) if value
        key = key.to_name.absolute(context)
        path_args[key] = value
      end
    end
    path path_args.merge(action: :new, mark: card.name)
  end

  # don't cache because it depends on update permission for another card
  view :configure_link, cache: :never, perms:  ->(fmt) { fmt.can_configure? } do
    configure_link
  end

  def can_configure?
    Card.fetch(card, :type, :structure, new: {}).ok? :update
  end

  view :configure_button, cache: :never, perms:  ->(fmt) { fmt.can_configure? } do
    configure_link "btn btn-outline-secondary"
  end

  def configure_link css_class=nil
    return "" unless Card.fetch(card, :type, :structure, new: {}).ok? :update

    voo.title ||= tr(:configure_card, cardname: safe_name)
    title = _render_title
    link_to_card card, title, path: { view: :bridge, bridge: { tab: :rules_tab },
                                      set: Card::Name[safe_name, :type] },
                              class: css_class
  end
end

include Basic

def cards_of_type_exist?
  !new_card? && Card.where(trash: false, type_id: id).exists?
end

def create_ok?
  Card.new(type_id: id).ok? :create
end

event :check_for_cards_of_type, after: :validate_delete do
  errors.add :cardtype, tr(:cards_exist, cardname: name) if cards_of_type_exist?
end

event :check_for_cards_of_type_when_type_changed, :validate, changing: :type do
  errors.add :cardtype, tr(:error_cant_alter, name: name) if cards_of_type_exist?
end

event :validate_cardtype_name, :validate, on: :save, changed: :name do
  if %r{[<>/]}.match?(name)
    errors.add :name, tr(:error_invalid_character_in_cardtype, banned: "<, >, /")
  end
end
