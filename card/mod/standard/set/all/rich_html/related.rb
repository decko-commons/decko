format :html do
  # the related view nests a related card with a submenu
  # the subcard is specified as an "item" card using the slot/voo api
  view :related, cache: :never do
    name, options = related_item
    return unless related_card name
    voo.show :toolbar, :menu, :help
    frame do
      voo.hide :header, :toggle
      nest @related_card, related_options(options)
    end
  end

  def related_item
    options = voo.items
    voo.items = {}
    name = options.delete :nest_name
    [name, options]
  end

  def related_card related_name
    @related_card = Card.fetch related_name.to_name.absolute_name(card.name), new: {}
  end

  def related_options opts
    opts[:view] ||= :open
    opts.reverse_merge!(show: :comment_box) if @related_card.show_comment_box_in_related?
    opts
  end
end
