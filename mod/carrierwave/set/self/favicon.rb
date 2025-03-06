format :html do
  view :source do
    source = card.type_id == Card::ImageID ? super() : nil
    source.present? ? source : nest(:logo, view: :source, size: voo.size)
  end

  view :link_tag, perms: :none do
    return unless (source = render :source, size: :small)

    tag :link, rel: "shortcut icon", href: source
  end

  def raw_help_text
    "A favicon (or shortcut icon) is a small image used by browsers to help identify " \
      "your website. [[http://www.decko.org/favicon|How to customize your favicon]]"
  end
end
