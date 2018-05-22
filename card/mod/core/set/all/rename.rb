event :rename, after: :set_name, on: :update do
  existing_card = Card.find_by_key_and_trash name.key, true
  return if !existing_card || existing_card == self
  existing_card.name = existing_card.name + "*trash"
  existing_card.rename_without_callbacks
  existing_card.save!
end

def suspend_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  tmp_name = "tmp:" + UUID.new.generate
  Card.where(id: id).update_all(name: tmp_name, key: tmp_name)
end

event :cascade_name_changes, :finalize, on: :update, changed: :name,
                                        before: :name_change_finalized do
  des = descendants
  @descendants = nil # reset

  des.each do |de|
    # here we specifically want NOT to invoke recursive cascades on these
    # cards, have to go this low level to avoid callbacks.
    Rails.logger.info "cascading name: #{de.name}"
    newname = de.name.swap name_before_last_save, name
    check_for_conflict de.name, newname
    Card.expire de.name # old name
    Card.where(id: de.id).update_all name: newname.to_s, key: newname.key
    de.update_referers = update_referers
    de.refresh_references_in
    Card.expire newname
  end
end

def check_for_conflict old_name, new_name
  return unless ActManager.include?(new_name) && (old_name.key != new_name.key)
  raise Card::Error, "conflict in act: "\
                     "the name of '#{old_name}' is changing to '#{new_name}' "\
                     "which is also a subcard of this act."
end
