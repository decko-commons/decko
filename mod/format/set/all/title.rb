format do
  view :title, compact: true, perms: :none do
    standard_title
  end

  def standard_title
    name_variant title_in_context(voo.title)
  end
end

format :html do
  view :title do
    show_view?(:title_link, :hide) ? render_title_link : render_title_no_link
  end

  view :title_link, compact: true, perms: :none do
    link_to_card card.name, render_title_no_link
  end

  view :title_no_link, compact: true, perms: :none do
    wrapped_title standard_title
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
    h super
  end

  def wrapped_title title
    wrap_with :span, class: classy("card-title"), title: title do
      title.to_name.parts.join wrapped_joint
    end
  end

  def wrapped_joint
    wrap_with :span, (voo.joint || "+"), classy("joint")
  end
end
