format :html do
  # view :nest_image, wrap: { modal: { footer: "" } }, unknown: true do
  #   @nest_snippet = NestParser.new_image card.name.field("image01")
  #   nest card.autoname(card.name.field("image01")), view: :new_image, type: :image
  # end
  #
  view :nest_image, unknown: true, cache: :never,
                    wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    nest_image_editor :overlay
  end

  view :modal_nest_image, unknown: true, cache: :never,
                          wrap: { slot: { class: "nodblclick" } }do
    nest_image_editor :modal
  end

  view :new_image, perms: :create, unknown: true, cache: :never do
    new_view_frame_and_form new_image_form_opts
  end

  def nest_image_editor editor_mode
    @tm_snippet_editor_mode = editor_mode
    @nest_snippet = NestEditor::NestParser.new_image card.autoname(card.name.field("image01").to_name.right)
    voo.show! :content_tab
    haml :reference_editor, ref_type: :nest, editor_mode: @tm_snippet_editor_mode,
         apply_opts: nest_apply_opts,
         snippet: nest_snippet
  end

  def new_image_form_opts
    { buttons: new_image_buttons,
      success: { view: :open_nest_editor, format: :js,
                 tinymce_id: Env.params[:tinymce_id] },
      "data-slotter-mode": "silent-success" }
  end

  def new_image_buttons
    button_formgroup do
      [standard_save_button(no_origin_update: true)]
        #modal_close_button("Cancel", class: "btn-sm")]
    end
  end
end

format :js do
  view :open_nest_editor, unknown: true do
    tm_id = if Env.params[:tinymce_id].present?
              "\"#{Env.params[:tinymce_id]}\""
            else
              '$(".tinymce-textarea").attr("id")'
            end
    <<-JAVASCRIPT.strip_heredoc
      tm = tinymce.get(#{tm_id});
      nest.insertNest(tm, "{{+#{card.name.tag}|size: medium}}");
    JAVASCRIPT
  end
end
