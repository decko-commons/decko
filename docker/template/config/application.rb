require File.expand_path("../boot", __FILE__)

require "decko/application"

module DockerDeck
  # sample decko application
  class Application < Decko::Application
    config.performance_logger = nil

    config.encoding = "utf-8"

    # Decko inherits most Ruby-on-Rails configuration options.
    # See http://guides.rubyonrails.org/configuring.html

    # EMAIL
    # Email is not turned on by default.  To turn it on, you need to change the
    # following to `true` and then add configuration specific to your site.
    # Learn more:
    #  https://guides.rubyonrails.org/configuring.html#configuring-action-mailer

    config.action_mailer.perform_deliveries = true
    # config.action_mailer.delivery_method  = ...
    # config.action_mailer.smtp_settings    = ...

    # Example configuration for mailcatcher, a simple smtp server.
    # See http://mailcatcher.me for more information
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

    # BACKGROUND
    # Decko lets you run some card events (like follower notifications) in the
    # background. This is off by default but can be turned on by changing the
    # `delaying` setting to `true`
    config.active_job.queue_adapter = :delayed_job
    config.delaying = false

    # CACHING
    # determines caching mechanism.  options include: file_store, memory_store,
    # mem_cache_store, dalli_store...
    #
    # for production, we highly recommend memcache
    # here's a sample configuration for use with the dalli gem
    config.cache_store = :mem_cache_store, []

    # FILES
    # config.paths["files"] = "files"
    # directory in which uploaded files are actually stored. (eg Image and File cards)

    if %w[DO AWS].member? ENV["DECKO_FILE_STORAGE"]
      credentials =
        if ENV["DECKO_FILE_STORAGE"] == "DO"
          { host: "https://nyc3.digitaloceanspaces.com",
            endpoint: "https://nyc3.digitaloceanspaces.com" }
        else
          { host: "s3.example.com",
            endpoint: "https://s3.example.com:8080" }
        end

      config.file_storage = :cloud
      config.file_default_bucket = :my_bucket
      config.file_buckets = {
        my_bucket: {
          directory: ENV["DECKO_FILE_BUCKET"],
          subdirectory: "files",
          credentials: credentials.merge(
            provider: "fog/aws",
            aws_access_key_id:     ENV["DECKO_FILE_KEY"],    # required
            aws_secret_access_key: ENV["DECKO_FILE_SECRET"], # required
            region:                ENV["DECKO_FILE_REGION"], # optional,
                                                             # defaults to "us-east-1"
          ),
          attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
          public: true,

          # if true then updating a file in that bucket will move it to the
          # default storage location
          read_only: false,

          # if public is set to false this option is needed
          authenticated_url_expiration: 180
        }
      }
    end

    # MISCELLANEOUS
    # config.read_only = true
    # defaults to false
    # disallows creating, updating, and deleting cards.

    # config.allow_inline_styles = false
    # don't strip style attributes (not recommended)
  end
end
