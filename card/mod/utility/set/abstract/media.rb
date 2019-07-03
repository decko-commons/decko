format :html do
  def image_card
    @image_card ||= card.fetch(trait: :image, new: {})
  end

  def text_with_image opts={}
    class_up "media-left", "m-2"
    @image_card = Card.cardish(opts[:image]) if opts[:image]
    haml :media_snippet, normalized_text_with_image_opts(opts)
  end

  private

  def normalized_text_with_image_opts opts
    opts.reverse_merge! title: _render_title, text: "", size: voo.size, media_opts: {}
  end
end
