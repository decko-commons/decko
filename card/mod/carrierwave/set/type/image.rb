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
    contextualize_path image.url
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
  view :inline, cache: :never do
    handle_source do |source|
      return source unless (mail = inherit :active_mail) &&
                           ::File.exist?(path = selected_version.path)
      url = attach_image mail, path
      image_tag url
    end
  end

  def attach_image mail, path
    mail.attachments.inline[path] = ::File.read path
    mail.attachments[path].url
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
