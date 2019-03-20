format :html do
  NEST_OPTIONS = [:view, :title, :show, :hide, :wrap, :help, :variant, :size, :params]
                 # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]

  view :nest_editor, cache: :never, template: :haml, wrap: { slot: { class: "_overlay d0-card-overlay card" } } do
    binding.pry
    @nest_editor_mode = :overlay
  end

  view :modal_nest_editor, cache: :never, wrap: :slot do
    modal_nest_editor
  end

  def nest_editor_tabs
    static_tabs({ rules: haml_partial(:rules), options: haml_partial(:options) },
                :options, "tabs")
  end

  def modal_nest_editor
    wrap_with :modal do
      haml :nest_editor, nest_editor_mode: "modal"
    end
  end

  def edit_nest
    @edit_nest ||= NestParser.new params[:edit_nest], default_nest_view, default_item_view
  end

  def tinymce_id
    params[:tinymce_id]
  end

  def apply_data
    data = { "data-tinymce-id": tinymce_id,
             "data-nest-start": params[:nest_start] || 0 }
    if params[:edit_nest].present?
      data["data-nest-size".to_sym] = edit_nest.raw.size
    end
    data
  end

  def default_nest_editor_item_options
    [[:view, default_item_view]]
  end

  def nest_option_name_select selected=nil, level=0
    classes = "form-control form-control-sm _nest-option-name"
    classes += " _new-row" if !selected
    select_tag "nest_option_name_#{unique_id}",
               nest_option_name_select_options(selected, level),
               class: classes, id: nil
    # id: nil ensures that select2 generates its own unique identifier
    # that ensures that we can clone this tag without breaking select2
  end

  def nest_option_name_select_options selected, level
    options = selected ? [] : ["--"]
    options += NEST_OPTIONS
    disabled = level == 0 ? edit_nest.options : edit_nest.item_options[level - 1]
    disabled = disabled&.map(&:first)
    options_for_select(options, disabled: disabled, selected: selected)
  end

  def nest_option_value_select value=nil #, items=false
    #select_tag "nest_option_value_#{unique_id}"
    text_field_tag "value", value,
                   class: "_nest-option-value form-control form-control-sm",
                  disabled: !value
  end
end
