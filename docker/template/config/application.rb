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
      address: ENV.fetch("DECKO_SMTP_ADDRESS", nil),
      domain: ENV["DECKO_SMTP_DOMAIN"] || ENV.fetch("DECKO_SMTP_ADDRESS", nil),
      user_name: ENV.fetch("DECKO_SMTP_USER", nil),
      password: ENV.fetch("DECKO_SMTP_PASSWORD", nil),
      authentication: ENV.fetch("DECKO_SMTP_AUTHENTICATION", nil),
      port: ENV.fetch("DECKO_SMTP_PORT", nil),
      enable_starttls_auto: false,
      ssl: true,
      tls: true
    }

    # FILES
    if ENV["DECKO_FILE_STORAGE"] == "AWS"
      config.file_storage = :cloud
      config.file_default_bucket = :my_bucket
      config.file_buckets = {
        my_bucket: {
          provider: "fog/aws",
          directory: ENV.fetch("DECKO_FILE_BUCKET", nil),
          subdirectory: "files",
          credentials: {
            provider: "AWS",
            host: ENV.fetch("DECKO_FILE_HOST", nil),
            endpoint: ENV.fetch("DECKO_FILE_ENDPOINT", nil),
            aws_access_key_id: ENV.fetch("DECKO_FILE_KEY", nil),
            aws_secret_access_key: ENV.fetch("DECKO_FILE_SECRET", nil),
            region: ENV.fetch("DECKO_FILE_REGION", nil),
            enable_signature_v4_streaming:
              ENV["ENABLE_SIGNATURE_V4_STREAMING"].present?
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
    config.deck_origin = ENV.fetch("DECKO_ORIGIN", nil)
    config.relative_url_root = ENV.fetch("DECKO_RELATIVE_URL_ROOT", nil)
  end
end
