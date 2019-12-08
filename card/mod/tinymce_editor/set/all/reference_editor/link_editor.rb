format :html do
  view :link_editor, cache: :never, unknown: true,
                     wrap: {
                       slot: { class: "_overlay d0-card-overlay card nodblclick" }
                     } do
    link_editor :overlay
  end

  view :modal_link_editor, cache: :never, unknown: true,
                           wrap: { slot: { class: "nodblclick" } } do
    modal_link_editor
  end

  def link_editor editor_mode
    @tm_snippet_editor_mode = editor_mode
    haml :reference_editor, ref_type: :link, editor_mode: @tm_snippet_editor_mode,
                            apply_opts: link_apply_opts, snippet: link_snippet
  end

  def modal_link_editor
    wrap_with :modal do
      link_editor :modal
    end
  end

  def link_snippet
    @link_snippet ||= LinkParser.new params[:tm_snippet_raw]
  end

  def link_apply_opts
    apply_tm_snippet_data link_snippet
  end
end
