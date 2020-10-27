# STAGE: validate

event :validate_name, :validate, on: :save, changed: :name, when: :no_autoname? do
  validate_legality_of_name
  return if errors.any?
  Card.write_to_soft_cache self
  validate_uniqueness_of_name
end

event :validate_uniqueness_of_name, skip: :allowed do
  # validate uniqueness of name

  return unless (existing_id = Card::Lexicon.id key) && existing_id != id
  # The above is a fast check but cannot detect if card is in trash

  # TODO: perform the following as a remote-only fetch (not yet supported)
  return unless (existing_card = Card.where(id: existing_id, trash: false).take)

  errors.add :name, tr(:error_name_exists, name: existing_card.name)
end

event :validate_legality_of_name do
  if name.length > 255
    errors.add :name, tr(:error_too_long, length: name.length)
  elsif name.blank?
    errors.add :name, tr(:error_blank_name)
  elsif name_incomplete?
    errors.add :name, tr(:is_incomplete)
  elsif !name.valid?
    errors.add :name, tr(:error_banned_characters, banned: Card::Name.banned_array * " ")
  elsif changing_existing_tag_to_junction?
    errors.add :name, tr(:error_name_tag, name: name)
  end
end

event :validate_key, after: :validate_name, on: :save, when: :no_autoname? do
  if key.empty?
    errors.add :key, tr(:error_blank_key) if errors.empty?
  elsif key != name.key
    errors.add :key, tr(:error_wrong_key, key: key, name: name)
  end
end

# STAGE: store

event :set_autoname, :prepare_to_store, on: :create, when: :autoname? do
  self.name = autoname rule(:autoname)
  rule_card(:autoname).update_column :db_content, name
  pull_from_trash!
end

event :expire_old_name, :store, changed: :name, on: :update do
  Director.expirees << name_before_act
end

event :update_lexicon_on_create, :finalize, changed: :name, on: :create do
  Card::Lexicon.add self
end

event :update_lexicon_on_rename, :finalize, changed: :name, on: :update do
  Card::Lexicon.update self
end

def lex
  simple? ? name : [left_id, right_id]
end

def old_lex
  if (old_left_id = left_id_before_act)
    [old_left_id, right_id_before_act]
  else
    name_before_act
  end
end

event :prepare_left_and_right, :store, changed: :name, on: :save do
  return if name.simple?
  prepare_side :left
  prepare_side :right
end

def prepare_side side
  side_id = send "#{side}_id"
  sidename = name.send "#{side}_name"
  prepare_obstructed_side(side, side_id, sidename) ||
    prepare_new_side(side, side_id, sidename)
end

def prepare_new_side side, side_id, sidename
  return unless side_id == -1 || !Card[side_id]&.real?

  sidecard = Director.card(sidename) || add_subcard(sidename)
  send "#{side}_id=", sidecard
end

def prepare_obstructed_side side, side_id, sidename
  return unless side_id && side_id == id
  clear_name sidename
  send "#{side}_id=", add_subcard(sidename)
  true
end

def name_incomplete?
  name.parts.include?("") && !superleft&.autoname?
end

def no_autoname?
  !autoname?
end

def autoname?
  name.blank? &&
    (@autoname_rule.nil? ? (@autoname_rule = rule(:autoname).present?) : @autoname_rule)
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
