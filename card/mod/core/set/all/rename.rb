event :rename_in_trash, after: :set_name, on: :update do
  existing_card = Card.find_by_key_and_trash name.key, true
  return if !existing_card || existing_card == self
  existing_card.name = existing_card.name + "*trash"
  existing_card.rename_in_trash_without_callbacks
  existing_card.save!
end

def suspend_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  tmp_name = "tmp:" + UUID.new.generate
  Card.where(id: id).update_all(name: tmp_name, key: tmp_name)
end

event :validate_renaming, :validate, on: :update, changed: :name do
  if db_content_is_changing?
    errors.add :content, tr(:cannot_change_content)
  end
  errors.add :type, tr(:cannot_change_type) if type_id_is_changing?
end

event :cascade_name_changes, :finalize, on: :update, changed: :name,
                                        before: :name_change_finalized do
  @descendants = nil # reset

  children.each do |child|
    Rails.logger.info "cascading name: #{child.name}"
    newname = child.name.swap name_before_last_save, name
    # not sure if this is still needed since we attach the children as subcards
    # (it used to be resolved right here without adding subcards)
    Card.expire child.name

    # superleft has to be the first argument. Otherwise the call of `name=` in
    # `assign_attributes` can cause problems because `left` doesn't find the new left.
    attach_subcard child.name, superleft: self, name: newname,
                               update_referers: update_referers
  end
end
