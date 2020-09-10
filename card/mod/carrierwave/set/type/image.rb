attachment :image, uploader: CarrierWave::ImageCardUploader

include File::SelectedAction

def create_versions? new_file
  new_file.extension != "svg"
end

def svg?
  image&.extension == ".svg"
end

format do
  include File::Format

  view :one_line_content do
    _render_core size: :icon
  end

  def short_content
    render_core size: :icon
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
      when voo.size.present?    then voo.size.to_sym
      when main?                then main_size
      else                           default_size
      end
    voo.size = :original if voo.size == :full
    voo.size
  end

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
