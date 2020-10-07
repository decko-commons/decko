attr_writer :empty_ok

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, after: :select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

# we need a card id for the path so we have to update db_content when we have
# an id
event :correct_identifier, :finalize, on: :create, when: proc { |c| !c.web? } do
  update_column(:db_content, attachment.db_content)
  expire
end

event :save_original_filename, :prepare_to_store, on: :save, when: :file_ready_to_save? do
  return unless @current_action
  @current_action.update! comment: original_filename
end

event :validate_file_exist, :validate, on: :create do
  return if empty_ok?
  if will_be_stored_as == :web
    errors.add "url is missing" if content.blank?
  elsif !attachment.file.present?
    errors.add attachment_name, "is missing"
  end
end

event :write_identifier, after: :save_original_filename, when: proc { |c| !c.web? } do
  self.content = attachment.db_content
end

def file_ready_to_save?
  attachment.file.present? &&
    !preliminary_upload? &&
    !save_preliminary_upload? &&
    attachment_is_changing?
end

def item_names _args={} # needed for flexmail attachments.  hacky.
  [name]
end

def original_filename
  return content.split("/").last if web?
  attachment.original_filename
end

def unfilled?
  !attachment.present? && !save_preliminary_upload? && !subcards? && blank_content?
end

def attachment_changed?
  send "#{attachment_name}_changed?"
end

def attachment_is_changing?
  send "#{attachment_name}_is_changing?"
end

def attachment_before_act
  send "#{attachment_name}_before_act"
end

def create_versions? _new_file
  true
end

def empty_ok?
  @empty_ok
end

def assign_set_specific_attributes
  # reset content if we really have something to upload
  self.content = nil if set_specific[attachment_name.to_s].present?
  super
end

def delete_files_for_action action
  with_selected_action_id(action.id) do
    attachment.file.delete
    attachment.versions.each_value do |version|
      version.file.delete
    end
  end
end

def revision action, before_action=false
  return unless (result = super)
  result[:empty_ok] = true
  result
end

def attachment_format ext
  if ext.present? && attachment && (original_ext = attachment.extension.sub(/^\./, ""))
    if ["file", original_ext].member? ext
      original_ext
    elsif (exts = Mime::Types[attachment.content_type])
      if exts.find { |mt| mt.extensions.member? ext }
        ext
      else
        exts[0].extensions[0]
      end
    end
  end
rescue => e
  Rails.logger.info "attachment_format issue: #{e.message}"
  nil
end
