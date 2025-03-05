require File.expand_path "boot", __dir__
require "decko/application"

module Decko
  # main deck application object
  class Deck < Application
    # Decko inherits most Ruby-on-Rails configuration options.
    # See http://guides.rubyonrails.org/configuring.html

    # CACHING
    config.cache_store = :mem_cache_store, []

    # EMAIL
    config.action_mailer.perform_deliveries = true
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("DECKO_SMTP_ADDRESS"),
      domain: ENV.fetch("DECKO_SMTP_DOMAIN") || ENV.fetch("DECKO_SMTP_ADDRESS"),
      user_name: ENV.fetch("DECKO_SMTP_USER"),
      password: ENV.fetch("DECKO_SMTP_PASSWORD"),
      authentication: ENV.fetch("DECKO_SMTP_AUTHENTICATION"),
      port: ENV.fetch("DECKO_SMTP_PORT"),
      enable_starttls_auto: false,
      ssl: true,
      tls: true
    }

    # FILES
    if ENV.fetch("DECKO_FILE_STORAGE") == "AWS"
      config.file_storage = :cloud
      config.file_default_bucket = :my_bucket
      config.file_buckets = {
        my_bucket: {
          provider: "fog/aws",
          directory: ENV.fetch("DECKO_FILE_BUCKET"),
          subdirectory: "files",
          credentials: {
            provider: "AWS",
            host: ENV.fetch("DECKO_FILE_HOST"),
            endpoint: ENV.fetch("DECKO_FILE_ENDPOINT"),
            aws_access_key_id: ENV.fetch("DECKO_FILE_KEY"),
            aws_secret_access_key: ENV.fetch("DECKO_FILE_SECRET"),
            region: ENV.fetch("DECKO_FILE_REGION"),
            enable_signature_v4_streaming:
              ENV.fetch("ENABLE_SIGNATURE_V4_STREAMING", nil).present?
          },
          attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
          public: true,
          read_only: false
          # if true then updating a file in that bucket will move it to the
          # default storage location
        }
      }
    end

    # ORIGIN AND RELATIVE_ROOT
    config.deck_origin = ENV.fetch("DECKO_ORIGIN")
    config.relative_url_root = ENV.fetch("DECKO_RELATIVE_URL_ROOT")
  end
end
