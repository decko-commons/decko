format :html do
  NEST_OPTIONS = %i[view title show hide wrap help variant size params].freeze
  # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  # TODO: connect to Card::View::Options
  # (that way a mod can add an option that becomes available to nests)

  view :nest_editor, cache: :never, unknown: true, template: :haml,
                     wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    @nest_editor_mode = :overlay
  end

  view :modal_nest_editor, cache: :never, unknown: true,
                           wrap: { slot: { class: "nodblclick" } } do
    modal_nest_editor
  end

  def nest_editor_tabs
    static_tabs({ options: haml_partial(:options),
                  rules: nest_rules_tab,
                  help: haml_partial(:help) },
                :options, "tabs")
  end

  def nest_rules_tab
    [
      empty_nest_name_alert(nest_snippet.name.blank?),
      nest_rules_editor
    ]
  end

  def nest_rules_editor
    if nest_snippet.name.blank?
      content_tag :div, "", class: "card-slot" # placeholder
    else
      nest(set_name_for_nest_rules, view: :nest_rules)
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

  def nest_snippet
    @nest_snippet ||= NestParser.new params[:tm_snippet_raw], default_nest_view, default_item_view
  end

  def left_type_for_nest_editor_set_selection
    card.type_name
  end

  def set_name_for_nest_rules
    nest_name = nest_snippet.name
    if left_type_for_nest_editor_set_selection
      [left_type_for_nest_editor_set_selection, nest_name, :type_plus_right]
    else
      [nest_name, :right]
    end
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
                 nest_snippet.options
               else
                 nest_snippet.item_options[level - 1] || default_nest_editor_item_options
               end

    disabled = disabled&.map(&:first)
    disabled&.delete selected if selected
    disabled
  end

  def nest_apply_opts
    apply_tm_snippet_data nest_snippet
  end

  def nest_option_value_select value=nil
    # select_tag "nest_option_value_#{unique_id}"
    text_field_tag "value", value,
                   class: "_nest-option-value form-control form-control-sm",
                   disabled: !value,
                   id: nil
  end
end
