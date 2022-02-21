def left_type_for_nest_editor_set_selection
  type_name
end

format :html do
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

  def nest_editor editor_mode, ref_type=:nest, title="Nest", editor=nil
    @tm_snippet_editor_mode = editor_mode
    voo.hide :content_tab unless show_content_tab?
    haml :reference_editor, title: title,
                            editor: editor || ref_type,
                            ref_type: ref_type,
                            editor_mode: @tm_snippet_editor_mode,
                            apply_opts: nest_apply_opts,
                            snippet: nest_snippet
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
    @nest_snippet ||=
      Card::Reference::NestParser.new params[:tm_snippet_raw]
  end

  def set_name_for_nest_rules
    nest_name = nest_snippet.name
    if (type_name = card.left_type_for_nest_editor_set_selection)
      [type_name, nest_name, :type_plus_right]
    else
      [nest_name, :right]
    end
  end

  def default_nest_editor_item_options
    []
    # [[:view, default_item_view]]
  end

  def demo
    _render_demo
  end

  def nest_apply_opts
    apply_tm_snippet_data nest_snippet
  end

  def known_nest_content
    voo.hide! :cancel_button
    add_name_context
    with_nest_mode :edit do
      wrap true do
        render_edit_inline
      end
    end
  end

  def unknown_nest_content
    voo.hide! :guide
    voo.show! :new_type_formgroup
    voo.buttons_view = :new_image_buttons
    wrap true do
      create_form success: { tinymce_id: Env.params[:tinymce_id] }
    end
    # framed_create_form
  end
end
