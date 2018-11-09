format :html do
  view :source do
    source = card.type_id == Card::ImageID ? super() : nil
    source.present? ? source : nest(:logo, view: :source, size: voo.size)
  end

  view :link_tag, perms: :none do
    return unless (source = render :source, size: :small)
    tag :link, rel: "shortcut icon", href: source
  end
end
