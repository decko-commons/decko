format :html do
  NEST_OPTIONS = %i[view title show hide wrap help variant size params].freeze
  # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  # TODO: connect to Card::View::Options
  # (that way a mod can add an option that becomes available to nests)

  view :nest_editor, cache: :never, template: :haml,
                     wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    @nest_editor_mode = :overlay
  end

  view :modal_nest_editor, cache: :never, wrap: { slot: { class: "nodblclick" } } do
    modal_nest_editor
  end

  def nest_editor_tabs
    static_tabs({ rules: nest_rules_tab, options: haml_partial(:options) },
                :options, "tabs")
  end

  def nest_rules_tab
    [
      empty_nest_name_alert(edit_nest.name.blank?),
      nest_rules_editor
    ]
  end

  def nest_rules_editor
    if edit_nest.name.blank?
      content_tag :div, "", class: "card-slot" # placeholder
    else
      nest([edit_nest.name, :right], view: :nest_rules)
    end
  end

  def empty_nest_name_alert show
    alert :warning, false, false,
          class: "mb-0 _empty-nest-name-alert #{'d-none' unless show}" do
      "nest name required" # LOCALIZE
    end
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
    data = { "data-tinymce-id": tinymce_id }
    data["data-nest-start".to_sym] = params[:nest_start] if params[:nest_start].present?
    data["data-nest-size".to_sym] = edit_nest.raw.size if params[:edit_nest].present?
    data
  end

  def default_nest_editor_item_options
    [[:view, default_item_view]]
  end

  def nest_option_name_select selected=nil, level=0
    classes = "form-control form-control-sm _nest-option-name"
    classes += " _new-row" unless selected
    select_tag "nest_option_name_#{unique_id}",
               nest_option_name_select_options(selected, level),
               class: classes, id: nil
    # id: nil ensures that select2 generates its own unique identifier
    # that ensures that we can clone this tag without breaking select2
  end

  def nest_option_name_select_options selected, level
    options = selected ? [] : ["--"]
    options += NEST_OPTIONS
    options_for_select(
      options, disabled: nest_option_name_disabled(selected, level),
               selected: selected
    )
  end

  def nest_option_name_disabled selected, level
    disabled = if level == 0
                 edit_nest.options
               else
                 edit_nest.item_options[level - 1] || default_nest_editor_item_options
               end

    disabled = disabled&.map(&:first)
    disabled&.delete selected if selected
    disabled
  end

  def nest_option_value_select value=nil
    # select_tag "nest_option_value_#{unique_id}"
    text_field_tag "value", value,
                   class: "_nest-option-value form-control form-control-sm",
                   disabled: !value,
                   id: nil
  end
end
