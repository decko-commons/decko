format :html do
  view :link_editor, cache: :never, unknown: true, template: :haml,
                     wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    @tm_snippet_editor_mode = :overlay
  end

  view :modal_link_editor, cache: :never, unknown: true,
                           wrap: { slot: { class: "nodblclick" } } do
    modal_link_editor
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end

  def modal_link_editor
    wrap_with :modal do
      haml :link_editor, tm_snippet_editor_mode: "modal"
    end
  end

  def link_snippet
    @link_snippet ||= LinkParser.new params[:tm_snippet_raw]
  end

  def link_apply_opts
    opts = apply_tm_snippet_data link_snippet
    #opts["data-dismiss"] = "modal" if modal_link_editor?
    #opts
  end
end
