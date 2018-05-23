VARIABLE_NAMES = {
  colors: %i[blue indigo purple pink red orange yellow green teal cyan
             white gray-100 gray-200 gray-300 gray-400 gray-500 gray-600 gray-700 gray-800
             gray-900 black],
  theme_colors: %i[primary secondary success info warning danger light dark
                   body-bg body-color]
}.freeze

# temporarily removed: link-color card-bg card-cap-bg
# bootstrap default for link-color uses the theme-color function which
# has to be defined between the theme-colors and that variable
# (see bootstrap's _variables.scss)
# TODO: deal with that

# @param name [String] a scss variable name (it can start with a $)
def variable_value name
  value_from_scss(name, content) ||
    value_from_variables_card(name) ||
    default_value_from_bootstrap(name)
end

def value_from_scss name, source
  name = name.to_s
  name = name[1..-1] if name.start_with?("$")
  source.match(definition_regex(name))&.capture(:value)
end

def value_from_variables_card name
  return unless (var_card = left.variables_card) && var_card.content.present?
  value_from_scss name, var_card.content
end

def definition_regex name
  /^(?<before>\s*\$#{name}\:\s*)(?<value>.+?)(?<after> !default;)$/
end

def default_value_from_bootstrap name
  value_from_scss name, bootstrap_variables_scss
end

def bootstrap_variables_scss
  @bootstrap_variables_scss ||= Type::CustomizedBootswatchSkin.read_bootstrap_variables
end

def colors
  @colors ||= variable_group_with_values :colors
end

def theme_colors
  @theme_colors ||= variable_group_with_values :theme_colors
end

def variable_group_with_values group
  VARIABLE_NAMES[group].each_with_object({}) do |name, h|
    h[name] = variable_value name
  end
end

format :html do
  view :editor, template: :haml do
    @colors = card.colors
    @theme_colors = card.theme_colors
  end

  def theme_color_picker name, value
    # value = value[1..-1] if value.start_with? "$"
    options = VARIABLE_NAMES[:colors].map { |var| "$#{var}" }
    options << value unless options.include? value
    select_tag "theme_colors[#{name}]", options_for_select(options, value),
               class: "tags form-control"
  end

  def select_button target=parent.card
    link_to_card target, "Select",
                 path: { action: :update, card: { content: "[[#{card.name}]]" } },
                 class: "btn btn-sm btn-outline-primary"
  end

  def customize_button target=parent.card
    link_to_card target, "Customize",
                 path: { action: :update, card: { content: "[[#{card.name}]]" },
                         customize: true },
                 class: "btn btn-sm btn-outline-primary"
  end
end

event :translate_variables_to_scss, :prepare_to_validate, on: :update do
  replace_values :colors
  replace_values :theme_colors
end

def replace_values group, prefix=""
  values = variable_values_from_params group
  values.each_pair do |name, val|
    if content.match definition_regex(name)
      content.gsub! definition_regex(name), "\\k<before>#{prefix}#{val}\\k<after>"
    else
      self.content += "$#{name}: #{prefix}#{val} !default;\n"
    end
  end
end

def variable_values_from_params group
  Env.params.dig(:group)&.slice(*VARIABLE_NAMES[group]) || {}
end
