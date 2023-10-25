# TODO: some of this should be moved to right/options!!
# or to type/JSON?

def options_hash
  json_options? ? options_card.parse_content : option_hash_from_names
end

def json_options?
  options_card&.type_id == JsonID
end

def option_hash_from_names
  option_names.each_with_object({}) do |name, hash|
    hash[name] = name
  end
end

def option_names
  if (selected_options = item_names)
    (standard_option_names + selected_options).uniq
  else
    standard_option_names
  end
end

def option_cards
  option_names.map do |name|
    Card.fetch name, new: {}
  end
end

def standard_option_names
  if json_options?
    options_hash.values.map(&:to_name)
  else
    option_names_from_items
  end
end

def option_names_from_items
  o_card = options_card
  limit = o_card.try(:default_limit).to_i
  context_name = right_type? ? nil : name
  o_card.item_names context: context_name, limit: limit
end

def options_card
  @options_card ||= rule_card(:content_options) || right_type_options || Card[:all]
end

def options_card_name
  options_card&.name&.url_key
end

private

def right_type_options
  Card.fetch [right.name, :type, :by_name] if right_type?
end

def right_type?
  right&.type_id == CardtypeID
end

format do
  delegate :options_card, :options_card_name, to: :card
end

format :html do
  def option_label option_name, id
    wrap_with :label, class: "form-check-label", for: id do
      option_label_text option_name
    end
  end

  def option_view
    @option_view ||= card.rule(:content_option_view) || :smart_label
  end

  def option_label_text option_name
    return option_name unless (option_card = Card.fetch option_name)

    nest option_card, view: option_view
  end
end
