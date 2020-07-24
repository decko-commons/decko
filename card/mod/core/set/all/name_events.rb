# STAGE: prepare to validate

event :set_autoname, :prepare_to_validate, on: :create do
  if name.blank? && (autoname_card = rule_card(:autoname))
    self.name = autoname autoname_card.db_content
    # FIXME: should give placeholder in approve phase
    # and finalize/commit change in store phase
    autoname_card.refresh.update_column :db_content, name
  end
end

# STAGE: validate

event :validate_name, :validate, on: :save, changed: :name do
  validate_legality_of_name
  return if errors.any?
  Card.write_to_soft_cache self
  validate_uniqueness_of_name
end

event :validate_uniqueness_of_name, skip: :allowed do
  # validate uniqueness of name

  return unless (existing_id = Card::Name.id key) &&
                (existing_card = Card.quick_fetch existing_id) &&
                existing_id != id

  errors.add :name, tr(:error_name_exists, name: existing_card.name)
end

event :validate_legality_of_name do
  if name.length > 255
    errors.add :name, tr(:error_too_long, length: name.length)
  elsif name.blank?
    errors.add :name, tr(:error_blank_name)
  elsif name.parts.include? ""
    errors.add :name, tr(:is_incomplete)
  elsif !name.valid?
    errors.add :name, tr(:error_banned_characters, banned: Card::Name.banned_array * " ")
  elsif changing_existing_tag_to_junction?
    errors.add :name, tr(:error_name_tag, name: name)
  end
end

event :validate_key, after: :validate_name, on: :save do
  if key.empty?
    errors.add :key, tr(:error_blank_key) if errors.empty?
  elsif key != name.key
    errors.add :key, tr(:error_wrong_key, key: key, name: name)
  end
end

# STAGE: store

event :expire_old_name, :store, changed: :name, on: :update do
  ActManager.expirees << name_before_act
end

event :temporary_name_hack, :finalize do
  Card::Name.reset_hashes # FIXME: temporary hack!
  Card::Name.generate_id_hash
end

event :set_left_and_right, :store, changed: :name, on: :save do
  if name.junction?
    %i[left right].each do |side|
      assign_side_id side
    end
  else
    self.left_id = self.right_id = nil
  end
end

# STAGE: finalize

event :name_change_finalized, :finalize, changed: :name, on: :save do
  # The events to update references has to happen after :cascade_name_changes,
  # but :cascade_name_changes is defined after the reference events and
  # and additionaly it is defined on :update but some of the reference
  # events are on :save. Hence we need this additional hook to organize these events.
end

private

def changing_existing_tag_to_junction?
  return false unless changing_name_to_junction?
  name_in_use_as_tag?
end

def name_in_use_as_tag?
  !Card.where(right_id: id, trash: false).take.nil?
end

def changing_name_to_junction?
  name.junction? && simple?
end

def assign_side_id side
  sidename = name.send "#{side}_name"
  sidecard = Card[sidename] || ActManager.card(sidename)

  # eg, renaming A to A+B
  if old_name_in_way? sidecard
    clear_name sidename
    sidecard = nil
  end
  send "#{side}_id=", side_id_or_card(sidecard, sidename)
end

def old_name_in_way? sidecard
  real? && sidecard&.simple? && id == sidecard&.id
end

def clear_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  Card.where(id: id).update_all(name: nil, key: nil)
end

def side_id_or_card sidecard, sidename
  if !sidecard
    add_subcard sidename.s 
  else
    # if sidecard doesn't have an id, it's already part of this act
    sidecard.id || sidecard
  end
end
