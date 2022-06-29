include_set Abstract::CqlSearch

def cql_content
  { type_id: id, sort_by: :name }
end

format :json do
  def add_autocomplete_item term
    return unless card.create_ok?

    { id: term, href: path(action: :new), text: add_autocomplete_item_text }
  end
end
