attachment :image, uploader: CarrierWave::ImageCardUploader

include File::SelectedAction

format do
  include File::Format

  view :closed_content do
    _render_core size: :icon
  end

  view :source do
    return card.content if card.web?
    image = selected_version
    return "" unless image.valid?
    internal_url image.url
  end
  
  def selected_version
    size = determine_image_size
    if size && size != :original
      card.image.versions[size]
    else
      card.image
    end
  end

  def handle_source
    super
  end

  def closed_size
    :icon
  end

  def main_size
    :large
  end

  def default_size
    :medium
  end

  def determine_image_size
    voo.size =
      case
      when nest_mode == :closed then closed_size
      when voo.size             then voo.size.to_sym
      when main?                then main_size
      else                           default_size
      end
    voo.size = :original if voo.size == :full
    voo.size
  end
end

format :html do
  include File::HtmlFormat

  # core HTML image view.
  view :core do
    handle_source do |source|
      if source.blank? || source == "missing"
        # FIXME - these images should be "broken", not "missing"
        # ("missing" is the view for "unknown" now, so we shouldn't further confuse things)
        "<!-- image missing #{safe_name} -->"
      else
        image_tag source
      end
    end
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
    return unless (last_change = card.last_change_on(:db_content, before: action))
    card.with_selected_action_id last_change.card_action_id do
      Card::Content::Diff.render_deleted_chunk _render_core
    end
  end

  def new_image action
    card.with_selected_action_id action.id do
      Card::Content::Diff.render_added_chunk _render_core
    end
  end
end

format do
  view :inline do
    _render_core
  end
end

format :email_html do
  view :inline do
    handle_source do |source|
      url_generator = voo.closest_live_option(:inline_attachment_url)
      path = selected_version.path
      return source unless url_generator && ::File.exist?(path)
      image_tag url_generator.call(path)
    end
  end
end

format :css do
  view :core do
    handle_source
  end

  view :content do  # why is this necessary?
    render_core
  end
end

format :file do
  include File::FileFormat

end
