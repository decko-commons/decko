format :html do
  def nest_option_classes
    "form-control"
  end

  def nest_option_name_select selected=nil, level=0,
                              include_view_option=true, template=false
    classes = "#{nest_option_classes} _nest-option-name"
    classes += " _new-row" unless selected
    classes += " _no-select2" if template
    select_tag "nest_option_name_#{unique_id}",
               nest_option_name_select_options(selected, level, include_view_option),
               class: classes, id: nil, "data-placeholder": "Select option"
    # id: nil ensures that select2 generates its own unique identifier
    # that ensures that we can clone this tag without breaking select2
  end

  def nest_option_name_select_options selected, level, include_view_option=true
    options = [""] + Card::Reference::NestParser::NEST_OPTIONS.dup
    options.delete :view unless include_view_option
    options_for_select(
      options, disabled: nest_option_name_disabled(selected, level),
               selected: selected
    )
  end

  def nest_option_name_disabled selected, level
    disabled = nest_option_name_disabled_options level
    disabled = disabled&.map(&:first)
    disabled&.delete selected if selected
    disabled
  end

  def nest_option_name_disabled_options level
    if level.zero?
      nest_snippet.options
    else
      nest_snippet.item_options[level - 1] || default_nest_editor_item_options
    end
  end

  def nest_view_select selected
    select_tag :view, options_for_select(view_list.unshift(nil), selected: selected),
               class: "tags _view-select _nest-option-value",
               "data-placeholder": "Select view"
  end

  def image_view_select selected
    select_tag :view, options_for_select(view_list.unshift(nil), selected: selected),
               class: "tags _image-view-select",
               "data-placeholder": "Select view"
  end

  def image_size_select
    select_tag :size, size_select_options(:medium), class: "_image-size-select"
  end

  def nest_option_value_select value=nil
    text_field_tag "value", value,
                   class: "_nest-option-value #{nest_option_classes}",
                   disabled: !value, id: nil
  end

  def nest_option_value_default_template
    text_field_tag "value", nil,
                   class: "_nest-option-template-default _nest-option-value " \
                          "#{nest_option_classes}",
                   id: nil
  end

  def size_select_options selected=:medium
    options_for_select(%w[icon small medium large original], selected: selected)
  end

  def nest_size_select_template
    nest_option_value_select_tag :size, size_select_options
  end

  def nest_view_select_template
    nest_option_value_select_tag :view, options_for_select(view_list)
  end

  def nest_show_and_hide_select_template
    nest_option_value_select_tag %i[show hide], options_for_select(all_views)
  end

  def nest_option_value_select_tag option_names, options
    wrap_classes =
      Array.wrap(option_names).map  { |name| "_nest-option-template-#{name}" }.join " "
    wrap_with :div, class: wrap_classes do
      select_tag :size, options,
                 class: "_no-select2 _nest-option-value #{nest_option_classes}"
    end
  end
end
