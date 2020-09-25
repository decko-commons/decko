attr_writer :bucket, :storage_type

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
  unless known_storage_type? will_be_stored_as
    errors.add :storage_type, tr(
      :unknown_storage_type,
      new_storage_type: @new_storage_type
    )
  end
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
  if content =~ %r{^:[^/]+/([^.]+)}
    Regexp.last_match(1) # current mod_file format
  else
    mod_from_deprecated_content
  end
end

# old format is still used in card_changes
def mod_from_deprecated_content
  return if content =~ /^\~/
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
  raise Card::Error, I18n.t(:error_invalid_storage_type,
                            scope: "mod.carrierwave.set.abstract.attachment",
                            type: type)
end

def storage_type_from_content
  case content
  when /^\(/           then :cloud
  when %r{/^https?\:/} then :web
  when /^~/            then :local
  when /^\:/           then :coded
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
  @storage_type = @new_storage_type
end

def storage_type_changed?
  @new_bucket || (@new_storage_type && @new_storage_type != storage_type) || @new_mod
end

def storage_type= value
  known_storage_type? value
  if @action == :update #&& storage_type != value
    # we cant update the storage type directly here
    # if we do then the uploader doesn't find the file we want to update
    @new_storage_type = value
  else
    @storage_type = value
  end
end

def with_storage_options opts={}
  old_values = {}
  validate_temporary_storage_type_change opts[:storage_type]
  %i[storage_type mod bucket].each do |opt_name|
    next unless opts[opt_name]
    old_values[opt_name] = instance_variable_get "@#{opt_name}"
    instance_variable_set "@#{opt_name}", opts[opt_name]
    @temp_storage_type = true
  end
  yield
ensure
  @temp_storage_type = false
  old_values.each do |key, val|
    instance_variable_set "@#{key}", val
  end
end

def temporary_storage_type_change?
  @temp_storage_type
end

def validate_temporary_storage_type_change new_storage_type=nil
  new_storage_type ||= @new_storage_type
  return unless new_storage_type
  unless known_storage_type? new_storage_type
    raise Error, tr(:unknown_storage_type, new_storage_type: new_storage_type)
  end

  if new_storage_type == :coded && codename.blank?
    raise Error, "codename needed for storage type :coded"
  end
end

def known_storage_type? type=storage_type
  type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
end
