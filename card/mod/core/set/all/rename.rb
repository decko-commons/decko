event :rename_in_trash, after: :expire_old_name, on: :update do
  existing_card = Card.find_by_key_and_trash name.key, true
  return if !existing_card || existing_card == self
  existing_card.name = existing_card.name + "*trash"
  existing_card.rename_in_trash_without_callbacks
  existing_card.save!
end

event :validate_renaming, :validate, on: :update, changed: :name, skip: :allowed do
  return if name_before_act&.to_name == name # just changing to new variant
  errors.add :content, tr(:cannot_change_content) if content_is_changing?
  errors.add :type, tr(:cannot_change_type) if type_is_changing?
  detect_illegal_compound_names
end

event :cascade_name_changes, :finalize, on: :update, changed: :name do
  each_descendant do |d|
    d.action = :update
    update_referers ? d.update_referers : d.update_referer_references_out
    d.refresh_references_in
    d.refresh_references_out
    d.expire
  end
end

def changed_from_simple_to_compound?
  name.compound? && name_before_act.to_name.simple?
end

def detect_illegal_compound_names
  return unless changed_from_simple_to_compound? && child_ids(:right).present?
  errors.add :name, "illegal name change; there are existing names ending in +" +
    name_before_act
end