format :html do
  view :title do
    title = wrapped_title(super())
    title = link_to_card card.name, title if show_view? :title_link, :hide
    add_name_context
    title
  end

  view :title_link do
    render_title show: :title_link
  end

  def title_with_link link_text
    link_to_card card.name, link_text
  end

  view :name do
    h(super())
  end

  def safe_name
    h super
  end

  def title_in_context title=nil
    h super
  end

  def wrapped_title title
    wrap_with :span, class: classy("card-title") do
      escaped_parts = title.to_name.parts.map { |part| h part }
      escaped_parts.join wrapped_joint
    end
  end

  def wrapped_joint
    wrap_with :span, "+", classy("joint")
  end
end
