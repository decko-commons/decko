format :html do
  NEST_OPTIONS = [:view, :title, :show, :hide, :wrap, :help, :variant, :size, :params]
    # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  view :nest_editor, cache: :never, template: :haml, wrap: :slot do
    "ASDf"
  end

  def edit_nest
    @edit_nest ||= NestParser.new params[:edit_nest], default_nest_view
  end

  def nest_id
    params[:nest_id]
  end

  def tinymce_id
    params[:tinymce_id]
  end

  def nest_option_name_select selected=nil
    new_row = !selected
    classes = "form-control form-control-sm _nest-option-name"
    classes += " _new-row" if new_row
    options = new_row ? ["--"] : []
    options += NEST_OPTIONS
    select_tag "nest_option_name_#{unique_id}",
               options_for_select(options, disabled: new_row && "view", selected: selected),
               class: classes, id: nil
  end

  def nest_option_value_select value=nil, items=false
    #select_tag "nest_option_value_#{unique_id}"
    text_field_tag "value", value,
                   class: "_nest-option-value form-control form-control-sm",
                  disabled: !value
  end
end
