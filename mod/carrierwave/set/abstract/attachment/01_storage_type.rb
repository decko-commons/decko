attr_writer :bucket, :new_storage_type
attr_writer :storage_type

event :stash_storage_type, :initialize, on: :update do
  if storage_type_from_content != @storage_type
    # we can't update the storage type until carrierwave has used the old storage type
    # to load the file we are updating
    @new_storage_type = @storage_type
    @storage_type = storage_type_from_content
  elsif coded? && !@new_mod
    @new_storage_type = storage_type_from_config
  end
end

event :storage_type_change, :store, on: :update, when: :storage_type_changed? do
  # carrierwave stores file if @cache_id is not nil
  attachment.cache_stored_file!
  # attachment.retrieve_from_cache!(attachment.cache_name)
  update_storage_attributes
  # next line might be necessary to move files to cloud

  # make sure that we get the new identifier
  # otherwise action_id will return wrong id for new identifier
  db_content_will_change!
  write_identifier
end

event :validate_storage_type, :validate, on: :save do
  return if known_storage_type? will_be_stored_as

  errors.add :storage_type, unknown_storage_type(@new_storage_type)
end

def will_be_stored_as
  @new_storage_type || storage_type
end

def read_only?
  web? || (cloud? && bucket_config[:read_only])
end

def cloud?
  storage_type == :cloud
end

def web?
  storage_type == :web
end

def local?
  storage_type == :local
end

def coded?
  storage_type == :coded
end

def remote_storage?
  cloud? || web?
end

def storage_type
  @storage_type ||=
    new_card? ? storage_type_from_config : storage_type_from_content
end

def deprecated_mod_file?
  content && (lines = content.split("\n")) && lines.size == 4
end

def mod
  @mod ||= coded? && mod_from_content
end

def mod_from_content
  if (m = content.match %r{^:[^/]+/([^.]+)})
    m[1] # current mod_file format
  else
    mod_from_deprecated_content
  end
end

# old format is still used in card_changes
def mod_from_deprecated_content
  return if content.match?(/^~/)
  return unless (lines = content.split("\n")) && lines.size == 4

  lines.last
end

def storage_type_from_config
  valid_storage_type ENV["FILE_STORAGE"] || Cardio.config.file_storage
end

def valid_storage_type storage_type
  storage_type.to_sym.tap do |type|
    invalid_storage_type! type unless type.in? valid_storage_type_list
  end
end

def valid_storage_type_list
  CarrierWave::FileCardUploader::STORAGE_TYPES
end

def invalid_storage_type! type
  raise Card::Error, t(:carrierwave_error_invalid_storage_type, type: type)
end

def storage_type_from_content
  @storage_type_from_content ||=
    case content
    when /^\(/          then :cloud
    when %r{/^https?:/} then :web
    when /^~/           then :local
    when /^:/           then :coded
    else
      if deprecated_mod_file?
        :coded
      else
        storage_type_from_config
      end
    end
end

def update_storage_attributes
  @mod = @new_mod if @new_mod
  @bucket = @new_bucket if @new_bucket
  @storage_type = @new_storage_type if @new_storage_type
end

def storage_type_changed?
  @new_bucket || @new_storage_type || @new_mod
end

def with_storage_options opts={}
  old_values = stash_and_set_storage_options opts
  validate_temporary_storage_type_change opts[:storage_type]
  @temp_storage_type = true
  yield
ensure
  @temp_storage_type = false
  old_values.each { |key, val| instance_variable_set "@#{key}", val }
end

def stash_and_set_storage_options opts
  %i[storage_type mod bucket].each_with_object({}) do |opt_name, old_values|
    next unless opts[opt_name]

    old_values[opt_name] = instance_variable_get "@#{opt_name}"
    instance_variable_set "@#{opt_name}", opts[opt_name]
    old_values
  end
end

def temporary_storage_type_change?
  @temp_storage_type
end

def validate_temporary_storage_type_change type=nil
  return unless type ||= @new_storage_type
  raise_error_if_type_invalid type
end

def raise_error_if_type_invalid type
  raise Error, unknown_storage_type(type) unless known_storage_type? type
  raise Error, "codename needed for storage type :coded" if coded_without_codename? type
end

def known_storage_type? type=storage_type
  type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
end

def unknown_storage_type type
  t :carrierwave_unknown_storage_type, new_storage_type: type
end

def coded_without_codename? type
  type == :coded && codename.blank?
end

def file_updated_at
  if coded?
    File.mtime file.path
  else
    updated_at
  end
end
