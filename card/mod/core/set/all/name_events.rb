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
  validate_uniqueness_of_name
end

event :validate_uniqueness_of_name do
  # validate uniqueness of name
  rel = Card.where key: name.key, trash: false
  rel = rel.where "id <> ?", id if id
  if (existing = rel.take)
    errors.add :name, "must be unique; '#{existing.name}' already exists."
  end
end

event :validate_legality_of_name do
  if name.length > 255
    errors.add :name, "is too long (255 character maximum)"
  elsif name.blank?
    errors.add :name, "can't be blank"
  elsif name.parts.include? ""
    errors.add :name, "is incomplete"
  elsif !name.valid?
    errors.add :name, "may not contain any of the following characters: " \
                      "#{Card::Name.banned_array * ' '}"
  elsif changing_existing_tag_to_junction?
    errors.add :name, "#{name} in use as a tag"
  end
end

event :validate_key, after: :validate_name, on: :save do
  if key.empty?
    errors.add :key, "cannot be blank" if errors.empty?
  elsif key != name.key
    errors.add :key, "wrong key '#{key}' for name #{name}"
  end
end

# STAGE: store

event :set_name, :store, changed: :name do
  expire
end

event :set_left_and_right, :store,
      changed: :name, on: :save do
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
  Auth.as_bot { Card.count_by_wql right_id: id }.positive?
end

def changing_name_to_junction?
  name.junction? && simple?
end

def assign_side_id side
  sidename = name.send "#{side}_name"
  sidecard = Card[sidename] || ActManager.card(sidename)

  # eg, renaming A to A+B
  old_name_in_way = (sidecard&.id && sidecard&.id == id)
  suspend_name(sidename) if old_name_in_way
  send "#{side}_id=", side_id_or_card(old_name_in_way, sidecard, sidename)
end

def side_id_or_card old_name_in_way, sidecard, sidename
  if !sidecard || old_name_in_way
    add_subcard(sidename.s)
  else
    # if sidecard doesn't have an id, it's already part of this act
    sidecard.id || sidecard
  end
end
