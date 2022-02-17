format :html do
  view :nest_image,
       unknown: true, cache: :never,
       wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    nest_image_editor :overlay
  end

  view :modal_nest_image, unknown: true, cache: :never,
                          wrap: { slot: { class: "nodblclick" } } do
    nest_image_editor :modal
  end

  view :new_image, perms: :create, unknown: true, cache: :never do
    voo.buttons_view = :new_image_buttons
    create_form success: { tinymce_id: Env.params[:tinymce_id], view: :open }
  end

  view :new_image_buttons do
    button_formgroup do
      [standard_save_button(no_origin_update: true, class: "_change-create-to-update")]
    end
  end

  def nest_image_editor editor_mode
    adapt_reference_editor_for_images
    nest_editor editor_mode, :nest, "Image", "image_nest"
  end

  def adapt_reference_editor_for_images
    nest_name = card.autoname("image01")
    voo.show! :content_tab
    @nest_content_tab = nest(nest_name, view: :new_image, type: :image, hide: :guide)

    #image_name = nest_name.to_name.right
    @nest_snippet = Card::Reference::NestParser.new_image nest_name
  end
end

format :js do
  view :change_create_to_update, unknown: true do
    "nest.changeCreateToUpdate(#{tinymce_id});"
  end

  view :open_nest_editor, unknown: true do
    <<-JAVASCRIPT.strip_heredoc
      tm = tinymce.get(#{tinymce_id});
      nest.insertNest(tm, "{{+#{card.name.tag}|view: content; size: medium}}");
    JAVASCRIPT
  end

  def tinymce_id
    if Env.params[:tinymce_id].present?
      "\"#{Env.params[:tinymce_id]}\""
    else
      '$(".tinymce-textarea").attr("id")'
    end
  end
end
