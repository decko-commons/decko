include_set Type::Scss
card_accessor :variables
card_accessor :stylesheets

# TODO: make it more visible/accessible/editable what's going on here in the content
# TODO: style: bootstrap cards load default bootstrap variables but
#       should depend on the theme specific variables
def content
  [
    Card["style: jquery-ui-smoothness"],
    Card["style: cards"],
    Card["style: right sidebar"],
    Card["font awesome"],
    Card["material icons"],
    Card[:bootstrap_functions],
    variables_card,
    Card[:bootstrap_variables],
    Card[:bootstrap_core],
    Card["style: bootstrap cards"],
    stylesheets_card.extended_item_cards
  ].flatten.compact.map(&:content).join "\n"
end

def theme_card_name
  "#{@theme} skin"
end

event :validate_theme_template, :validate, on: :create do
  if (@theme = Env.params[:theme]).present?
    if Card.fetch_type_id(theme_card_name) != Card::SkinID
      errors.add :abort, "not a valid theme: #{@theme}"
    elsif !Dir.exist?(source_dir)
      errors.add :abort, "can't find source for theme \"#{@theme}\""
    end
  end
end

event :copy_theme, :prepare_to_store, on: :create do
  add_subfield_from_file :variables
  if @theme
    theme_style = add_subfield_from_file :bootswatch
    add_subfield :stylesheets, type_id: SkinID, content: "[[#{theme_style.name}]]"
  else
    add_subfield :stylesheets, type_id: SkinID
  end
end

def source_dir
  @source_dir ||= ::File.expand_path "../../../vendor/bootswatch/dist/#{@theme}", __FILE__
end

def add_subfield_from_file field_name, file_name=nil
  file_name ||= field_name
  content = content_from_file(file_name) || ""
  add_subfield field_name, type_id: ScssID, content: content
end

def content_from_file subfield
  @theme.present? &&
    (path = ::File.join source_dir, "_#{subfield}.scss") &&
    ::File.exist?(path) &&
    ::File.read(path)
end

format :html do
  def edit_fields
    [[:variables, { title: "" }],
     [:stylesheets, { title: "additional css changes" }]]
  end

  view :closed_content do
    ""
  end
end
