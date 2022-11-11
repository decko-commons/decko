format :html do
  include File::HtmlFormat

  # core HTML image view.
  view :core do
    return card.attachment.read.html_safe if svg?

    with_valid_source do |source|
      image_tag source, alt: card.name
    end
  end

  def with_valid_source
    handle_source do |source|
      if source.blank? || source == "missing"
        # FIXME: these images should be "broken", not "missing"
        invalid_image source
      else
        yield source
        # consider title..
      end
    end
  end

  view :full_width do
    with_valid_source do |source|
      image_tag source, alt: card.name, class: "w-100"
    end
  end

  def invalid_image source
    # ("missing" is the view for "unknown" now, so we shouldn't further confuse things)
    "<!-- invalid image for #{safe_name}; source: #{source} -->"
  end

  def preview
    return if card.new_card? && !card.preliminary_upload?

    wrap_with :div, class: "attachment-preview",
                    id: "#{card.attachment.filename}-preview" do
      _render_core size: :medium
    end
  end

  def show_action_content_toggle? _action, _view_type
    true
  end

  view :content_changes do
    content_changes card.last_action, :expanded
  end

  def content_changes action, diff_type, hide_diff=false
    voo.size = diff_type == :summary ? :icon : :medium
    [old_image(action, hide_diff), new_image(action)].compact.join
  end

  def old_image action, hide_diff
    return if hide_diff || !action

    old_image_change action do |old_action_id|
      card.with_selected_action_id old_action_id do
        Card::Content::Diff.render_deleted_chunk _render_core
      end
    end
  end

  def old_image_change action
    return unless (change = card.last_change_on(:db_content, before: action))

    yield change.card_action_id
  end

  def new_image action
    card.with_selected_action_id action.id do
      Card::Content::Diff.render_added_chunk _render_core
    end
  end

  def goto_autocomplete_icon
    render :core, size: :small
  end
end
