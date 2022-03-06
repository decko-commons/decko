format do
  ONE_LINE_CHARACTER_LIMIT = 60

  # override to customize by set
  def chunk_list
    :default
  end

  view :one_line_content do
    with_nest_mode :compact do
      one_line_content
    end
  end

  # DEPRECATED
  view :closed_content, :one_line_content

  view :raw_one_line_content do
    raw_one_line_content
  end

  view :label do
    card.label.to_s
  end

  view :smart_label, cache: :never, unknown: true do
    label_with_description render_label, label_description
  end

  def label_with_description label, description
    return label unless description

    "#{label} #{popover_link description}"
  end

  # TODO: move this into a nest once popovers are stub safe
  def label_description
    return unless (desc = card.fetch :description)

    desc.format.render_core
  end

  def raw_one_line_content
    cut_with_ellipsis render_raw
  end

  def one_line_content
    Content.smart_truncate render_core
  end

  def cut_with_ellipsis text, limit=one_line_character_limit
    if text.size <= limit
      text
    else
      "#{text[0..(limit - 3)]}..."
    end
  end

  def one_line_character_limit
    voo.size || ONE_LINE_CHARACTER_LIMIT
  end
end

format :html do
  view :hidden_content_field, unknown: true, cache: :never do
    hidden_field :content, class: "d0-card-content"
  end
end
