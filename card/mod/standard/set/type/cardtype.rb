include_set Abstract::WqlSearch

def cql_content
  { type_id: id, sort: :name }
end

def related_sets with_self=false
  sets = []
  sets << ["#{name}+*type", Card::Set::Type.label(name)] if known?
  sets + super
end

format :html do
  view :type, unknown: true do
    link_to_card card.type_card, nil, class: "cardtype"
  end

  def type_formgroup args={}
    if card.cards_of_type_exist?
      wrap_with :div, tr(:cards_exist, cardname: safe_name)
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
    voo.title ||= tr(:add_card, cardname: safe_name)
    link_to render_title, add_link_opts(opts)
  end

  def add_link_opts opts
    modal = opts.delete :modal
    modal = true if modal.nil?
    opts[:path] = add_path(modal ? :new_in_modal : :new)
    modal ? modal_link_opts(opts) : opts
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
  view :configure_link, cache: :never, perms: ->(fmt) { fmt.can_configure? } do
    configure_link
  end

  def can_configure?
    Card.fetch(card, :type, :structure, new: {}).ok? :update
  end

  view :configure_button, cache: :never, denial: :blank,
                          perms:  ->(fmt) { fmt.can_configure? } do
    configure_link "btn btn-secondary"
  end

  def configure_link css_class=nil
    return "" unless Card.fetch(card, :type, :structure, new: {}).ok? :update

    voo.title ||= tr(:configure_card, cardname: safe_name.pluralize)
    title = _render_title
    link_to_card card, title, path: { view: :bridge, bridge: { tab: :rules_tab },
                                      set: Card::Name[safe_name, :type] },
                              class: css_classes("configure-type-link ml-3", css_class)
  end

  private

  def process_voo_params path_args
    context = ((@parent&.card) || card).name
    Rack::Utils.parse_nested_query(voo.params).each do |key, value|
      value = value.to_name.absolute(context) if value
      key = key.to_name.absolute(context)
      path_args[key] = value
    end
  end
end

include Basic

def cards_of_type_exist?
  !new_card? && Card.where(trash: false, type_id: id).exists?
end

def create_ok?
  Card.new(type_id: id).ok? :create
end

def was_cardtype?
  type_id_before_act == Card::CardtypeID
end

event :check_for_cards_of_type, after: :validate_delete do
  errors.add :cardtype, tr(:cards_exist, cardname: name) if cards_of_type_exist?
end

event :check_for_cards_of_type_when_type_changed,
      :validate, changing: :type, when: :was_cardtype? do
  if cards_of_type_exist?
    errors.add :cardtype, tr(:error_cant_alter, name: name_before_act)
  end
end

event :validate_cardtype_name, :validate, on: :save, changed: :name do
  if %r{[<>/]}.match?(name)
    errors.add :name, tr(:error_invalid_character_in_cardtype, banned: "<, >, /")
  end
end
