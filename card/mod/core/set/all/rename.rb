event :rename_in_trash, after: :expire_old_name, on: :update do
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

event :validate_renaming, :validate, on: :update, changed: :name, skip: :allowed do
  return if name_before_act&.to_name == name # just changing to new variant
  errors.add :content, tr(:cannot_change_content) if db_content_is_changing?
  if type_id_is_changing?
    errors.add :type, tr(:cannot_change_type)
  end
end

event :cascade_name_changes, :finalize, on: :update, changed: :name,
                                        before: :name_change_finalized do
  @descendants = nil # reset
  skip_rename_events! if act_card?

  children.each do |child|
    Rails.logger.debug "cascading name: #{child.name}"
    newname = child.name.swap name_before_last_save, name
    # superleft has to be the first argument. Otherwise the call of `name=` in
    # `assign_attributes` can cause problems because `left` doesn't find the new left.
    attach_subcard child.name, superleft: self, name: newname,
                               update_referers: update_referers
  end
end

private

def skip_rename_events!
  # these are skipped for children, because they've already been called in the act card
  skip_event! :validate_uniqueness_of_name, :validate_renaming, :check_permissions
  skip_event! :set_read_rule if name.simple?
end
