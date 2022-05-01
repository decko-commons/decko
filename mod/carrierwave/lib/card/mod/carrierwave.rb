Cardio::Railtie.config.tap do |config|
  config.files_web_path = "files"
  config.file_storage = :local
  config.file_buckets = {}
  config.file_default_bucket = nil
end
