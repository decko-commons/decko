format :html do
  view :title do
    title = wrapped_title super()
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

  def safe_name
    h super
  end

  def title_in_context title=nil
    title = title&.html_safe
    # escape titles generated from card names, but not those set explicitly
    h super(title)
  end

  def wrapped_title title
    wrap_with :span, class: classy("card-title") do
      title.to_name.parts.join wrapped_joint
    end
  end

  def wrapped_joint
    wrap_with :span, "+", classy("joint")
  end
end
