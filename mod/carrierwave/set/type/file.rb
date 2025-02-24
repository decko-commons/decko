attachment :file, uploader: CarrierWave::FileCardUploader

# sheared method for action identification
module SelectedAction
  def select_action_by_params params
    # skip action table lookups for current revision
    rev_id = params[:rev_id]
    super unless rev_id && rev_id == last_content_action_id
  end

  def last_content_action_id
    # find action id from content (saves lookups)
    aid = db_content.to_s.split(%r{[/.]})[-2]
    aid.number? ? aid.to_i : nil
  end
end
include SelectedAction

format do
  view :source do
    source
  end

  view :core do
    handle_source do |source|
      card_url source
    end
  end

  def short_content
    number_to_human_size card.attachment.size
  end

  def handle_source
    rescuing_file_source_error do
      src = source
      if src.blank?
        ""
      elsif block_given?
        yield src
      else
        src
      end
    end
  end

  def source
    file = card.attachment
    file.valid? ? contextualize_path(file.url) : ""
  end

  def selected_version
    card.attachment
  end

  private

  def rescuing_file_source_error
    yield
  rescue StandardError => e
    Rails.logger.info "Error with file source: #{e.message}"
    t :carrierwave_file_error
  end
end

format :file do
  # NOCACHE because returns send_file args.  not in love with this...
  view :core, cache: :never do
    # this means we only support known formats.  dislike.
    attachment_format = card.attachment_format(params[:format])
    return _render_not_found unless attachment_format
    return card.format(:html).render_core if card.remote_storage?

    set_response_headers
    args_for_send_file
  end

  private

  def args_for_send_file
    file = selected_version
    [file.path, { type: file.content_type,
                  filename: "#{card.name.safe_key}#{file.extension}",
                  x_sendfile: true,
                  disposition: disposition }]
  end

  def disposition
    if params[:disposition]
      params[:disposition]
    elsif params[:format] == "file"
      "attachment"
    else
      "inline"
    end
  end

  def set_response_headers
    return unless params[:explicit_file] && (response = controller&.response)

    response.headers["Expires"] = 1.year.from_now.httpdate
    # currently using default "private", because proxy servers could block
    # needed permission checks
    # r.headers["Cache-Control"] = "public"
  end
end

format :json do
  view(:content) { render_core }
end

format :html do
  view :core do
    handle_source do |source|
      haml :core, source: source
    end
  end

  view :input do
    if card.no_upload?
      text_field :content, class: "d0-card-content"
    else
      haml :file_chooser, action_text: file_chooser_action_text
    end
  end

  view :preview_editor, unknown: true, cache: :never do
    haml :preview_editor
  end

  def file_chooser_action_text
    action = card.new_card? ? "Add" : "Replace"
    "#{action} #{humanized_attachment_name}..."
  end

  def humanized_attachment_name
    card.attachment_name.to_s.humanize
  end

  def preview
    ""
  end

  def cached_upload_card_name
    Card::Env.params[:attachment_upload].gsub(/\[\w+\]$/, "[action_id_of_cached_upload]")
  end

  def preview_editor_delete_text
    t :carrierwave_delete
  end
end
