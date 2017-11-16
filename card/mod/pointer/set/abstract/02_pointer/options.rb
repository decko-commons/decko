
def option_names
  result_names = configured_option_names

  if (selected_options = item_names)
    result_names += selected_options
    result_names.uniq!
  end
  result_names
end

def configured_option_names
  if (oc = options_rule_card)
    oc.item_names context: name,
                  limit: oc.respond_to?(:default_limit) ? oc.default_limit : 0
  else
    Card.search({ sort: "name", limit: 50, return: :name },
                "option names for pointer: #{name}")
  end
end

def option_cards
  option_names.map do |name|
    Card.fetch name, new: {}
  end
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
    o_card = Card.fetch(option_name)
    (o_card && o_card.label) || option_name
  end

  # @param option_type [String] "checkbox" or "radio"
  def option_description option_type, option_name
    return "" unless (description = pointer_option_description(option_name))
    %(<div class="#{option_type}-option-description">#{description}</div>)
  end

  def pointer_option_description option
    pod_name = card.rule(:options_label) || "description"
    dcard = Card["#{option}+#{pod_name}"]
    return unless dcard && dcard.ok?(:read)
    with_nest_mode :normal do
      subformat(dcard).render_core
    end
  end
end