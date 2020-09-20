def field tag, opts={}
  Card.fetch name.field(tag), opts
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
end

def field? tag
  field(tag) || subfield(tag)
end

def subcards
  @subcards ||= Card::Subcards.new self
end

def subcards?
  subcards.present?
end

def expire_subcards
  subcards.clear
end

# phase_method :attach_subcard, before: :store do |name_or_card, args=nil|
# TODO: handle differently in different stages
def add_subcard name_or_card, args={}
  subcards.add name_or_card, args
end
alias_method :attach_subcard, :add_subcard

def add_subcard! name_or_card, args={}
  subcard = subcards.add name_or_card, args
  subcard.director.reset_stage
  subcard
end
alias_method :attach_subcard!, :add_subcard!

# phase_method :attach_subfield, before: :approve do |name_or_card, args=nil|
def attach_subfield name_or_card, args={}
  subcards.add_field name_or_card, args
end
alias_method :add_subfield, :attach_subfield

def attach_subfield! name_or_card, args={}
  subcard = subcards.add_field name_or_card, args
  subcard.director.reset_stage
  subcard
end

def detach_subcard name_or_card
  subcards.remove name_or_card
end
alias_method :remove_subcard, :detach_subcard

def detach_subfield name_or_card
  subcards.remove_field name_or_card
end
alias_method :remove_subfield, :detach_subfield

def clear_subcards
  subcards.clear
end

# ensures subfield is present
# does NOT override subfield content if already present
def ensure_subfield field_name, args={}
  if subfield_present? field_name
    subfield field_name
  else
    add_subfield field_name, args
  end
end

def subfield_present? field_name
  subfield(field_name)&.content&.present?
end

def deep_clear_subcards
  subcards.deep_clear
end

def handle_subcard_errors
  subcards.each do |subcard|
    subcard.errors.each do |field, err|
      subcard_error subcard, field, err
    end
    subcard.errors.clear
  end
end

def subcard_error subcard, field, err
  err = "#{field} #{err}" unless %i[content abort].member? field
  errors.add subcard.name.from(name), err
end

event :reject_empty_subcards, :prepare_to_validate do
  subcards.each_with_key do |subcard, key|
    next unless subcard.new? && subcard.unfilled?
    remove_subcard(key)
    director.subdirectors.delete(subcard)
  end
end

# check when deleting field that left has not also been deleted
def trashed_left?
  l = left
  !l || l.trash
end

# check when renaming field that it is not actually the same field
# (eg on a renamed trunk)
def same_field?
  (left_id == left_id_before_act) && (right_id == right_id_before_act)
end
