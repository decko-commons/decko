format :html do
  view :nest_image, wrap: :modal do
    nest card.autoname(card.name.field("image01")), view: :new_image, type: :image
  end

  view :new_image , perms: :create, tags: :unknown_ok, cache: :never do
    with_nest_mode :edit do
      voo.title ||= new_view_title if new_name_prompt?
      voo.show :help
      frame_and_form :create, new_image_form_opts do
        [
          new_view_name,
          new_view_type,
          _render_content_formgroup,
          _render_new_image_buttons
        ].flatten
      end
    end
  end

  def new_image_form_opts
    { success: { view: :open_nest_editor, format: :js,
                 tinymce_id: Env.params[:tinymce_id] }, "data-slotter-mode": "silent-success" }
  end

  view :new_image_buttons do
    button_formgroup do
      [standard_save_and_close_button(no_origin_update: true), standard_cancel_button(cancel_button_new_args)]
    end
  end

  # def standard_create_image_button
  #   submit_button class: "submit-button create-submit-button"
  # end
end

format :js do
  view :open_nest_editor do
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
