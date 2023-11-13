
basket[:tasks] = {}
basket[:config_title] = {
  basic: "Basic configuration",
  editor: "Editor configuration"
}
# to add an admin task:
#
# basket[:tasks][TASK_NAME] = {
#   irreversible: TRUE/FALSE,
#   execute_policy: -> { TASK_CODE },
#   mod: MODNAME
# }
#
# Then add two lines in the locales containing the link text and the description:

#   MOD_task_TASK_NAME_link_text: LINK_TEXT
#   MOD_task_TASK_NAME_description: DESCRIPTION

def mod_cards_with_config
  Card.search(type_id: Card::ModID).select { |mod| mod.admin_config.present? }
end

def create_admin_items mod, category, subcategory, values
  Array.wrap(values).map do |value|
    config = ::AdminItem.new(mod, category, subcategory, value)
    config.roles = if Card::Codename.exist?(config.codename.to_sym)
                     Card[config.codename.to_sym].responsible_role
                   else
                     []
                   end
    config
  end
end

def responsible_set_card
  Card.fetch([self, :self, :update], new: {})
end

def responsible_role
  responsible_set_card.find_existing_rule_card.item_cards.map(&:codename)
end

def all_configs
  mod_cards_with_config.map(&:admin_config_objects).flatten
end

def all_admin_configs_grouped_by property1, property2=nil
  return admin_config_by_by property1, property2 if property2

  result = Hash.new { |hash, k| hash[k] = [] }
  all_configs.each_with_object(result) do |config, h|
    property_values = Array.wrap(config.send(property1))
    property_values.each do |value|
      h[value] << config
    end
  end
end

def all_admin_configs_of_category category
  all_admin_configs_grouped_by(:category)[category]
end

def config_codenames_grouped_by_title configs
  configs&.group_by { |c| c.title }&.map do |title, grouped_configs|
    [title, grouped_configs.map { |config| config.codename.to_sym }]
  end
end

format :html do
  def section title, content
    "<p>#{section_title(title)}#{content}</p>"
  end

  def section_title title
    "<h3>#{title}</h3>"
  end

  def list_section title, items, item_view=:bar
    return unless items.present?

    section title, list_section_content(items, item_view)
  end

  def nested_list_section title, grouped_items
    output [
      section_title(title),
      wrap_with(:div, accordion_sections(grouped_items), class: "accordion")
    ]
  end

  def accordion_sections grouped_items
    return unless grouped_items.present?

    grouped_items.map do |title, codenames|
      accordion_item(title,
                     subheader: nil,
                     body: list_section_content(codenames),
                     open: false,
                     context: title.hash)
    end.join " "
  end

  def list_section_content items, item_view=:bar
    items&.map do |card|
      nest card, view: item_view
    end&.join(" ")
  end
end

private

def admin_config_by_by property1, property2
  result = Hash.new { |hash, k| hash[k] = Hash.new { |hash2, k2| hash2[k2] = [] } }
  all_configs.each_with_object(result) do |config, h|
    property1_values = Array.wrap(config.send(property1))
    property2_values = Array.wrap(config.send(property2))

    property1_values.each do |p1v|
      property2_values.each do |p2v|
        h[p1v][p2v] << config
      end
    end
  end
end
