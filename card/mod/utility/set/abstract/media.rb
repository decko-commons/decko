format :html do
  def image_card
    @image_card ||= card.fetch(trait: :image)
  end

  def image_src opts
    return "" unless image_card
    nest(image_card, view: :source, size: opts[:size])
  end

  def image_alt
    image_card&.name
  end

  def text_with_image_args opts
    opts.reverse_merge! title: _render_title, text: "", src: image_src(opts),
                        alt: image_alt, size: :original
  end

  def text_with_image opts={}
    @image_card = Card.cardish(opts[:image]) if opts[:image]
    opts[:media_opts] = {} unless opts[:media_opts]
    text_with_image_args opts
    haml :media_snippet, opts
  end
end
