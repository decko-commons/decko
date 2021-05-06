event :validate_not_alias, :validate, on: :save do
  errors.add t(:alias_cards_no_children) if alias? && type_code != :alias
end

def alias?
  name.parts.any? { |p| Card[p]&.alias? }
end

def target_name
  Card::Name[
    name.parts.map do |p|
      part = Card[p]
      part&.alias? ? part.target_name : p
    end
  ]
end

def target_card
  Card.fetch target_name, new: {}
end
