format :html do
  NEST_OPTIONS = %i[view title show hide wrap help variant size params].freeze
  # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  # TODO: connect to Card::View::Options
  # (that way a mod can add an option that becomes available to nests)

  view :nest_editor, cache: :never, unknown: true,
                     wrap: {
                       slot: { class: "_overlay d0-card-overlay card nodblclick" }
                     } do
    nest_editor :overlay
  end

  view :modal_nest_editor, cache: :never, unknown: true,
                           wrap: { slot: { class: "nodblclick" } } do
    modal_nest_editor
  end

  view :nest_content, perms: :create, cache: :never, unknown: true, wrap: :slot do
    if card.known?
      known_nest_content
    else
      unknown_nest_content
    end
  end

  def nest_editor editor_mode
    @tm_snippet_editor_mode = editor_mode
    voo.hide :content_tab unless show_content_tab?
    haml :reference_editor, ref_type: :nest, editor_mode: @tm_snippet_editor_mode,
                            apply_opts: nest_apply_opts,
                            snippet: nest_snippet
  end

  def nest_editor_tabs
    tab_hash = {}
    tab_hash[:content] = nest_content_tab if voo.show? :content_tab
    tab_hash.merge! options: haml(:_options, snippet: nest_snippet),
                    rules: nest_rules_tab,
                    help: haml(:_help)
    tabs tab_hash, default_active_tab
  end

  def show_content_tab?
    !card.is_structure?
  end

  def default_active_tab
    voo.show?(:content_tab) ? :content : :options
  end

  def nest_content_tab
    name_dependent_slot do
      @nest_content_tab || nest(card.name.field(nest_snippet.name),
                                view: :nest_content, hide: :guide)
    end
  end

  def nest_rules_tab
    name_dependent_slot do
      nest(set_name_for_nest_rules, view: :nest_rules)
    end
  end

  def name_dependent_slot
    result = [empty_nest_name_alert(nest_snippet.name.blank?)]
    result <<
      if nest_snippet.name.blank?
        content_tag :div, "", class: "card-slot" # placeholder
      else
        yield
      end
    result
  end

  def empty_nest_name_alert show
    alert :warning, false, false,
          class: "mb-0 _empty-nest-name-alert #{'d-none' unless show}" do
      "nest name required" # LOCALIZE
    end
  end

  def modal_nest_editor
    wrap_with :modal do
      nest_editor :modal
    end
  end

  def nest_snippet
    @nest_snippet ||= NestParser.new params[:tm_snippet_raw],
                                     default_nest_view, default_item_view
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

  def known_nest_content
    voo.hide! :cancel_button
    add_name_context
    with_nest_mode :edit do
      frame do
        [
          render_edit_inline
        ]
      end
    end
  end

  def unknown_nest_content
    voo.hide! :guide
    voo.show! :new_type_formgroup
    new_view_frame_and_form buttons: new_image_buttons,
                            success: { tinymce_id: Env.params[:tinymce_id] }
  end
end
