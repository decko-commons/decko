format :html do
  view :source do
    source = super()
    source.present? ? source : nest(:logo, view: :source, size: voo.size)
  end

  view :link_tag do
    return unless (source = render :source, size: :small)
    tag :link, rel: "shortcut icon", href: source
  end
end
