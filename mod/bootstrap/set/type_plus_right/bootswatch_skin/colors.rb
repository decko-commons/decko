include_set Abstract::SkinField

VARIABLE_NAMES = {
  colors: %i[blue indigo purple pink red orange yellow green teal cyan black white
             gray-100 gray-200 gray-300 gray-400 gray-500
             gray-600 gray-700 gray-800 gray-900],
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
  /^(?<before>\s*\$#{name}:\s*)(?<value>.+?)(?<after> !default;)$/
end

def default_value_from_bootstrap name
  value_from_scss name, bootstrap_variables_scss
end

def bootstrap_variables_scss
  @bootstrap_variables_scss ||= left.read_bootstrap_variables
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

def virtual?
  new?
end

def ok_to_create
  left.parent? && super
end

def ok_to_update
  left.parent? && super
end

format :html do
  view :input, template: :haml do
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

  before :bar_right do
    voo.show :edit_button
  end

  view :core, template: :haml do
    @colornames_with_value = card.colors.with_indifferent_access
    @colors = @colornames_with_value.to_a[0..9]
    @grays = @colornames_with_value.to_a[10..-1]
    @themecolornames_with_value =
      card.theme_colors.map  do |k, v|
        v.starts_with?("$") ? [k, @colornames_with_value[v[1..-1]]] : [k, v]
      end
  end

  view :bar_middle do
    <<-HTML
      <div class="colorpicker-element">
        <div class="input-group-addon">
          <span class="bg-body border p-1">Text</span>
          <span class="bg-dark text-light border p-1">Nav</span>
            <i class="bg-primary"></i>
          <i class="bg-secondary"></i>
        </div>
      </div>
    HTML
  end
end

event :translate_variables_to_scss, :prepare_to_validate, on: :update do
  replace_values :colors
  replace_values :theme_colors
end

private

def replace_values group, prefix=""
  values = variable_values_from_params group
  values.each_pair do |name, val|
    if content.match? definition_regex(name)
      content.gsub! definition_regex(name), "\\k<before>#{prefix}#{val}\\k<after>"
    else
      self.content += "$#{name}: #{prefix}#{val} !default;\n"
    end
  end
end

def variable_values_from_params group
  Env.params[group]&.slice(*VARIABLE_NAMES[group]) || {}
end
