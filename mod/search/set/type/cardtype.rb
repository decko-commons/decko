include_set Abstract::CqlSearch

# should name sorting be hard coded here??
def cql_content
  { type_id: id, sort_by: :name }
end

def add_autocomplete_ok?
  card.create_ok?
end

format :html do
  def add_autocomplete_item_path
    path action: :new
  end
end
