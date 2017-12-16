include_set Abstract::WqlSearch

def wql_hash
  { type_id: id }
end

format :html do
  view :type do |args|
    args[:type_class] = "no-edit" if card.cards_of_type_exist?
    super args
  end

  view :type_formgroup do
    if card.cards_of_type_exist?
      wrap_with :div, tr(:cards_exist, cardname: card.name)
    else
      super()
    end
  end

  view :add_link do |args|
    voo.title ||= tr(:add_card, cardname: card.name)
    title = _render_title args
    link_to title, path: _render_add_path(args), class: args[:css_class]
  end

  view :add_button, view: :add_link
  def default_add_button_args args
    args[:css_class] = "btn btn-outline-secondary"
  end

  view :add_url do |args|
    card_url _render_add_path(args)
  end

  view :add_path do |_args|
    path_args = {}
    if voo.params
      context = ((@parent && @parent.card) || card).name
      Rack::Utils.parse_nested_query(voo.params).each do |key, value|
        value = value.to_name.absolute(context) if value
        key = key.to_name.absolute(context)
        path_args[key] = value
      end
    end
    path_args[:action] = "new"
    page_path card.name, path_args
  end
end

include Basic

def follow_label
  default_follow_set_card.follow_label
end

def followed_by? user_id=nil
  default_follow_set_card.all_members_followed_by? user_id
end

def default_follow_set_card
  # FIXME: use codename
  Card.fetch("#{name}+*type")
end

def cards_of_type_exist?
  !new_card? && Card.where(trash: false, type_id: id).exists?
end

def create_ok?
  Card.new(type_id: id).ok? :create
end

event :check_for_cards_of_type, after: :validate_delete do
  if cards_of_type_exist?
    errors.add :cardtype, tr(:cards_exist, name: name)
  end
end

event :check_for_cards_of_type_when_type_changed, :validate, changed: :type do
  if cards_of_type_exist?
    errors.add :cardtype, tr(:error_cant_alter, name: name)
  end
end
