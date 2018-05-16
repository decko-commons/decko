format :html do
  view :template_link, cache: :never do
    wrap do
      voo.title = parent.voo.nest_syntax if parent
      "{{#{link_to_template_editor}}}"
    end
  end

  def link_to_template_editor
    link_to_view :template_editor, voo.title, class: "slotter",
                                              path: { slot: { title: voo.title } }
  end

  # TODO: hamlize
  view :template_editor do
    wrap { haml :template_editor }
  end

  def frame_header
    voo.show?(:template_closer) ? template_frame_header : super
  end

  def template_frame_header
    [render_template_closer, _render_header]
  end

  # no slot, because frame is inside template_editor's slot
  def standard_frame slot=true
    voo.show?(:template_closer) ? super(false) : super
  end

  view :template_editor_frame do
    voo.title = card.label
    voo.hide :set_label
    frame do
      _render_core
    end
  end

  view :template_closer do
    wrap_menu do
      wrap_with "div", class: "card-menu template-closer" do
        link_to_view :template_link, icon_tag("remove"), class: "slotter"
      end
    end
  end
end
