format :html do
  view :template_link, cache: :never do
    wrap do
      voo.title = parent.voo.nest_syntax if parent
      "{{#{link_to_template_editor}}}"
    end
  end

  def link_to_template_editor
    link_to_view :modal_nest_rules, voo.title
    # modal_link voo.title, path: { view: :nest_rules, slot: { title: voo.title } }
  end
end
