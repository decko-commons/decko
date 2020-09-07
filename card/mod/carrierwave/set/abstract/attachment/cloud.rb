event :change_bucket_if_read_only, :initialize,
      on: :update, when: :change_bucket_if_read_only? do
  @new_storage_type = storage_type_from_config
end

event :validate_storage_type_update, :validate, on: :update, when: :cloud? do
  # FIXME: make it possible to retrieve the file from cloud storage
  #   to store it somewhere else. Currently, it only works to change the
  #   storage type if a new file is provided
  #   i.e. `update storage_type: :local` fails but
  #        `update storage_type: :local, file: [file handle]` is ok
  if cloud? && storage_type_changed? && !attachment_is_changing?
    errors.add :storage_type, tr(:moving_files_is_not_supported)
  end
end

def bucket
  @bucket ||= cloud? &&
    (new_card_bucket || bucket_from_content || bucket_from_config)
end

def new_card_bucket
  return unless new_card?
  # If the file is assigned before the bucket option we have to
  # check if there is a bucket options in set_specific.
  # That happens for exmaple when the file appears before the bucket in the
  # options hash:
  #   Card.create file: file_handle, bucket: "my_bucket"
  set_specific[:bucket] || set_specific["bucket"] || bucket_from_config
end

def bucket_config
  @bucket_config ||= load_bucket_config
end

def load_bucket_config
  return {} unless bucket
  bucket_config = Cardio.config.file_buckets &&
    Cardio.config.file_buckets[bucket.to_sym]
  bucket_config &&= bucket_config.symbolize_keys
  bucket_config ||= {}
  # we don't want :attributes hash symbolized, so we can't use
  # deep_symbolize_keys
  bucket_config[:credentials] &&= bucket_config[:credentials].symbolize_keys
  ensure_bucket_config do
    load_bucket_config_from_env bucket_config
  end
end

def ensure_bucket_config
  config = yield
  unless config.present?
    raise Card::Error, "couldn't find configuration for bucket #{bucket}"
  end
  unless config[:credentials]
    raise Card::Error, "couldn't find credentials for bucket #{bucket}"
  end
  config
end

def load_bucket_config_from_env config
  config ||= {}
  CarrierWave::FileCardUploader::CONFIG_OPTIONS.each do |key|
    next if key.in? %i[attributes credentials]
    replace_with_env_variable config, key
  end
  config[:credentials] ||= {}
  load_bucket_credentials_from_env config[:credentials]
  config.delete :credentials unless config[:credentials].present?
  config
end

def load_bucket_credentials_from_env cred_config
  cred_opt_pattern =
    Regexp.new(/^(?:#{bucket.to_s.upcase}_)?CREDENTIALS_(?<option>.+)$/)
  ENV.keys.each do |env_key|
    next unless (m = cred_opt_pattern.match(env_key))
    replace_with_env_variable cred_config, m[:option].downcase.to_sym,
                              "credentials"
  end
end

def replace_with_env_variable config, option, prefix=nil
  env_key = [prefix, option].compact.join("_").upcase
  new_value = ENV["#{bucket.to_s.upcase}_#{env_key}"] ||
    ENV[env_key]
  config[option] = new_value if new_value
end

def bucket_from_content
  return unless content
  content.match(/^\((?<bucket>[^)]+)\)/) { |m| m[:bucket] }
end

def bucket_from_config
  Cardio.config.file_default_bucket ||
    (Cardio.config.file_buckets&.keys&.first)
end

def change_bucket_if_read_only?
  cloud? && bucket_config[:read_only] && attachment_is_changing?
end

def bucket= value
  if @action == :update
    @new_bucket = value
  else
    @bucket = value
  end
end
