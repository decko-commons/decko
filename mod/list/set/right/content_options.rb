assign_type :list

def default_limit
  cql_limit = fetch_query.limit if respond_to?(:fetch_query)
  cql_limit || 50
end

format :html do
  def quick_edit
    card.left.prototype_default_card.try(:show_content_options?) ? super : ""
  end

  def quick_editor
    wrap_type_formgroup do
      type_field class: "type-field rule-type-field _submit-on-select"
    end +
      wrap_content_formgroup do
        text_field :content, class: "d0-card-content _submit-after-typing"
      end
  end

  def visible_cardtype_groups
    { "Organize" => %w[List Pointer] }
  end
end
