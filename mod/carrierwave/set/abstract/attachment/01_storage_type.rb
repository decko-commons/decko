attr_writer :bucket, :new_storage_type

event :update_storage, :store, on: :update, when: :storage_changed? do
  send "#{attachment_name}=", current.attachment.file unless @attaching
  write_identifier
end

event :validate_storage_type, :validate, on: :save do
  errors.add :storage_type, unknown_storage_type unless known_storage_type?
end

def current
  @current ||= refresh true
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

def storage_type= value
  @explicit_storage_type = true
  @storage_type = value&.to_sym
end

def storage_type
  @storage_type ||= new_card? ? storage_type_from_config : storage_type_from_content
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

def storage_changed?
  (storage_type != current.storage_type) ||
    (bucket != current.bucket) ||
    (mod != current.mod)
end

def known_storage_type?
  storage_type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
end

def unknown_storage_type
  t :carrierwave_unknown_storage_type, new_storage_type: storage_type
end

def file_updated_at
  if coded?
    File.mtime file.path
  else
    updated_at
  end
rescue Errno::ENOENT # no file at path
  nil
end
