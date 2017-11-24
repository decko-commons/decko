def field tag, opts={}
  Card.fetch name.field(tag), opts
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
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
def attach_subcard name_or_card, args={}
  subcards.add name_or_card, args
end
alias_method :add_subcard, :attach_subcard

def attach_subcard! name_or_card, args={}
  subcard = subcards.add name_or_card, args
  subcard.director.reset_stage
  subcard
end

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

def subfield_present? field_name
  (field_card = subfield(field_name)) && field_card.content.present?
end

def deep_clear_subcards
  subcards.deep_clear
end

event :handle_subcard_errors do
  subcards.each do |subcard|
    subcard.errors.each do |field, err|
      subcard_error subcard, field, err
    end
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
