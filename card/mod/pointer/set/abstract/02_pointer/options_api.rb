# TODO: some of this should be moved to right/options!!

def options_hash
  json_options? ? options_card.parse_content : option_hash_from_names
end

def json_options?
  options_card&.type_id == Card::JsonID
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

def options_rule_card
  rule_card :options
end

def standard_option_names
  if json_options?
    options_hash.values.map(&:to_name)
  else
    options_card.item_names context: name, limit: rule_card.try(:default_limit).to_i
  end
end

def options_card
  options_rule_card || Card[:all]
end

def options_card_name
  options_rule_card&.name&.url_key || ":all"
end

format do
  def options_card_name
    card.options_card_name
  end
end

format :html do
  def option_label option_name, id
    %(<label for="#{id}">#{option_label_text option_name}</label>)
  end

  def option_label_text option_name
    Card.fetch(option_name)&.label || option_name
  end

  # @param option_type [String] "checkbox" or "radio"
  def option_description option_type, option_name
    return "" unless (description = option_description_core(option_name))
    %(<div class="#{option_type}-option-description">#{description}</div>)
  end

  def option_description_core option
    # DISCUSS: "options label" is an obscure rule. still support?
    desc_name = card.rule(:options_label) || "description"
    return unless (desc_card = Card[option, desc_name])
    nest desc_card, { view: :core }, nest_mode: :normal
  end
end
