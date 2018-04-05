VARIABLE_NAMES = {
  colors: %i[blue indigo purple pink red orange yellow green teal cyan
             white gray-100 gray-200 gray-300 gray-400 gray-500 gray-600 gray-700 gray-800
             gray-900 black],
  theme_colors: %i[primary secondary success info warning danger light dark
                   body-bg body-color link-color card-bg card-cap-bg]
}.freeze

def variable_value name
  value_from_scss_source(name, content) || default_value_from_bootstrap(name)
end

def value_from_scss_source name, source
  name = name.to_s
  name = name[1..-1] if name.start_with?("$")
  source.match(/^\s*\$#{name}\:\s*(?<value>.+?) !default;\n/)&.capture(:value)
end

def default_value_from_bootstrap name
  value_from_scss_source name, bootstrap_variables_scss
end

def bootstrap_variables_scss
  @bootstrap_variables ||= read_bootstrap_variables
end

def read_bootstrap_variables
  path = File.expand_path("../../../../vendor/bootstrap/scss/_variables.scss", __FILE__)
  File.exist?(path) ? File.read(path) : ""
end

def colors
  variable_group_with_values :colors
end

def theme_colors
  variable_group_with_values :theme_colors
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
    select_tag name, options_for_select(COLORS.keys, value)
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
