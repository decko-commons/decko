format :html do
  view :header do
    voo.hide! :toggle
    main_header
  end

  def main_header
    header_wrap _render_header_title
  end

  def header_wrap content=nil
    voo&.hide :header_toggle
    res = haml :header_wrap, content: (block_given? ? yield : output(content))
    return res #unless voo&.show?(:header_toggle)
    #content_toggle res
  end

  view :header_title do
    header_title_elements
  end

  def header_title_elements
    [_render_toggle, content_toggle(_render_title)]
  end

  def show_draft_link?
    card.drafts.present? && @slot_view == :edit
  end

  view :toggle do
    content_toggle
  end

  def content_toggle text=""
    return if text.nil?
    verb, adjective, direction = toggle_verb_adjective_direction
    text = icon_tag(direction.to_sym) if text.blank?
    link_to_view adjective, text,
                 title: "#{verb} #{card.name}",
                 class: "#{verb}-icon toggler nodblclick"
  end

  def toggle_view
    @toggle_mode == :close ? :open : :closed
  end

  def toggle_verb_adjective_direction
    if @toggle_mode == :close
      %w[open open expand]
    else
      %w[close closed collapse_down]
    end
  end

  view :navbar_links do
    wrap_with :ul, class: "navbar-nav" do
      item_links.map do |link|
        wrap_with(:li, class: "nav-item") { link }
      end.join "\n"
    end
  end

  def structure_editable?
    card.structure && card.template.ok?(:update)
  end
end


