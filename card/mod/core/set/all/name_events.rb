# STAGE: validate

event :validate_name, :validate, on: :save, changed: :name, when: :no_autoname? do
  validate_legality_of_name
  return if errors.any?

  Card.write_to_soft_cache self
  validate_uniqueness_of_name
end

# called by validate_name
event :validate_uniqueness_of_name, skip: :allowed do
  return unless (existing_id = Card::Lexicon.id key) && existing_id != id
  # The above is a fast check but cannot detect if card is in trash

  # TODO: perform the following as a remote-only fetch (not yet supported)
  return unless (existing_card = Card.where(id: existing_id, trash: false).take)

  errors.add :name, t(:core_error_name_exists, name: existing_card.name)
end

# called by validate_name
event :validate_legality_of_name do
  if name.length > 255
    errors.add :name, t(:core_error_too_long, length: name.length)
  elsif name.blank?
    errors.add :name, t(:core_error_blank_name)
  elsif name_incomplete?
    errors.add :name, t(:core_is_incomplete)
  elsif !name.valid?
    errors.add :name, t(:core_error_banned_characters,
                        banned: Card::Name.banned_array * " ")
  elsif changing_existing_tag_to_compound?
    errors.add :name, t(:core_error_name_tag, name: name)
  end
end

event :validate_key, after: :validate_name, on: :save, when: :no_autoname? do
  if key.empty?
    errors.add :key, t(:core_error_blank_key) if errors.empty?
  elsif key != name.key
    errors.add :key, t(:core_error_wrong_key, key: key, name: name)
  end
end

event :validate_renaming, :validate, on: :update, changed: :name, skip: :allowed do
  return if name_before_act&.to_name == name # just changing to new variant

  errors.add :content, t(:core_cannot_change_content) if content_is_changing?
  errors.add :type, t(:core_cannot_change_type) if type_is_changing?
  detect_illegal_compound_names
end

# STAGE: store

event :expire_old_name, :store, changed: :name, on: :update do
  Director.expirees << name_before_act
end

event :rename_in_trash, after: :expire_old_name, on: :update do
  existing_card = Card.find_by_key_and_trash name.key, true
  return if !existing_card || existing_card == self

  existing_card.rename_as_trash_obstacle
end

event :prepare_left_and_right, :store, changed: :name, on: :save do
  return if name.simple?

  prepare_side :left
  prepare_side :right
end

# as soon as the name has an id, we have to update the lexicon.
# (the after_store callbacks are called _right_ after the storage)
event :update_lexicon, :store, changed: :name, on: :save do
  director.after_store do |card|
    lexicon_action = @action == :create ? :add : :update
    Card::Lexicon.send lexicon_action, card
  end
end

protected

def rename_as_trash_obstacle
  self.name = "#{name}*trash"
  rename_in_trash_without_callbacks
  save!
end

private

def name_incomplete?
  name.parts.include?("") && !superleft&.autoname?
end

def changed_from_simple_to_compound?
  name.compound? && name_before_act.to_name.simple?
end

def detect_illegal_compound_names
  return unless changed_from_simple_to_compound? && child_ids(:right).present?

  errors.add :name, "illegal name change; existing names end in +#{name_before_act}"
end

def changing_existing_tag_to_compound?
  changing_name_to_compound? && name_in_use_as_tag?
end

def name_in_use_as_tag?
  !Card.where(right_id: id, trash: false).take.nil?
end

def changing_name_to_compound?
  name.compound? && simple?
end

def old_name_in_way? sidecard
  real? && sidecard&.simple? && id == sidecard&.id
end

def clear_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.where(id: id).update_all(name: nil, key: nil, left_id: nil, right_id: nil)
  Card.expire name
  Card::Lexicon.cache.reset # probably overkill, but this for an edge case...
  # Card::Lexicon.delete id, key
end

def prepare_side side
  side_id = send "#{side}_id"
  sidename = name.send "#{side}_name"
  prepare_obstructed_side(side, side_id, sidename) ||
    prepare_new_side(side, side_id, sidename)
end

def prepare_new_side side, side_id, sidename
  return unless side_id == -1 || !Card[side_id]&.real?

  sidecard = Director.card(sidename) || subcard(sidename)
  send "#{side}_id=", sidecard
end

def prepare_obstructed_side side, side_id, sidename
  return unless side_id && side_id == id

  clear_name sidename
  send "#{side}_id=", subcard(sidename)
  true
end
