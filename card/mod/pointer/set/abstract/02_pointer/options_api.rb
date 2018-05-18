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
  option_names_from_rules || option_names_from_search
end

def option_names_from_rules
  return unless (rule_card = options_rule_card)
  rule_card.item_names context: name, limit: rule_card.try(:default_limit).to_i
end

# TODO: let's either (a) document why it's useful to hard-code a search for the
# first 50 names as options, or (b) remove this.  EFM votes for B
def option_names_from_search
  Card.search({ sort: "name", limit: 50, return: :name },
              "option names for pointer: #{name}")
end

format do
  def options_card_name
    (oc = card.options_rule_card) ? oc.name.url_key : ":all"
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
