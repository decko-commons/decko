format :html do
  def autosaved_draft_link opts={}
    text = opts.delete(:text) || "autosaved draft"
    opts[:path] = { edit_draft: true }
    add_class opts, "navbar-link"
    link_to_view :edit, text, opts
  end
end
