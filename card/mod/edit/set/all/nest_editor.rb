format :html do
  NEST_OPTIONS = [:view, :title, :show, :hide, :wrap, :help, :variant, :size, :params]
    # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  view :nest_editor, cache: :never, template: :haml, wrap: :slot do
  end

  def nest_option_name_select new_row=false
    classes = "form-control form-control-sm _nest-option-name"
    classes += " _new-row" if new_row
    options = new_row ? ["--"] : []
    options += NEST_OPTIONS
    select_tag "nest_option_name_#{unique_id}",
               options_for_select(options, disabled: new_row && "view"),
               class: classes, id: nil
  end

  def nest_option_value_select new_row=false, items=false
    #select_tag "nest_option_value_#{unique_id}"
    text = new_row ? "" : (items ? default_item_view : default_nest_view)
    text_field_tag "value", text, class: "_nest-option-value form-control form-control-sm",
                                disabled: new_row
  end
end
