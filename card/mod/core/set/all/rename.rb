event :rename, after: :set_name, on: :update do
  existing_card = Card.find_by_key_and_trash cardname.key, true
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
    Card.expire de.name # old name
    newname = de.cardname.swap name_before_last_save, name
    Card.where(id: de.id).update_all name: newname.to_s, key: newname.key
    de.update_referers = update_referers
    de.refresh_references_in
    Card.expire newname
  end
end
