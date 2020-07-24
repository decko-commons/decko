event :rename_in_trash, after: :expire_old_name, on: :update do
  existing_card = Card.find_by_key_and_trash name.key, true
  return if !existing_card || existing_card == self
  existing_card.name = existing_card.name + "*trash"
  existing_card.rename_in_trash_without_callbacks
  existing_card.save!
end

event :validate_renaming, :validate, on: :update, changed: :name, skip: :allowed do
  return if name_before_act&.to_name == name # just changing to new variant
  errors.add :content, tr(:cannot_change_content) if db_content_is_changing?
  errors.add :type, tr(:cannot_change_type) if type_id_is_changing?
end

event :cascade_name_changes, :finalize, on: :update, changed: :name,
                                        before: :name_change_finalized do

end
