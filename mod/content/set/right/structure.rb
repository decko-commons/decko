include_set Abstract::TemplatedNests

def item_names args={}
  item_strings(args).compact.map(&:to_name)
end

format :rss do
  def raw_feed_items
    [card]
  end
end

format :html do
  view :one_line_content do
    "#{_render_type} : #{_render_raw}"
  end

  def visible_cardtype_groups
    hash = All::CardtypeGroups::GROUP.slice("Text")
    hash["Organize"] = ["Search", "Nest list"]
    hash
  end
end

event :update_structurees_references, :integrate,
      when: :update_structurees_references? do
  return unless (query = structuree_query)

  Auth.as_bot do
    query.run.each(&:update_references_out)
  end
end

def update_structurees_references?
  db_content_changed? || action == :delete
end

event :reset_cache_to_use_new_structure,
      before: :update_structurees_references do
  Card::Cache.reset_shared
  Card::Cache.reset_temp
end

event :update_structurees_type, :finalize,
      changed: :type_id, when: proc { |c| c.assigns_type? } do
  update_structurees type_id: type_id
end

def structuree_names
  return [] unless (query = structuree_query(return: :name))

  Auth.as_bot do
    query.run
  end
end

def update_structurees args
  # NOTE: that this is not smart about overriding templating rules
  # for example, if someone were to change the type of a
  # +*right+*structure rule that was overridden
  # by a +*type plus right+*structure rule, the override would not be respected.
  return unless (query = structuree_query(return: :id))

  Auth.as_bot do
    query.run.each_slice(100) do |id_batch|
      Card.where(id: id_batch).update_all args
    end
  end
end

def structuree_query args={}
  set_card = trunk
  return unless set_card.type_id == SetID

  set_card.fetch_query args
end
