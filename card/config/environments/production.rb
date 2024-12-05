# -*- encoding : utf-8 -*-

Cardio.application.class.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true
  config.view_cache = true

  # temporary fix for formerly autoloaded files that stopped autoloading in Rails 5
  # TODO: configure eager_load_paths explicitly (and remove this)
  config.enable_dependency_loading = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = defined?(Rails::Server)

  # Compress JavaScripts and CSS
  # config.assets.compress = true
  #
  # # Don't fallback to assets pipeline if a precompiled asset is missed
  # config.assets.compile = false
  #
  # # Generate digests for assets URLs
  # config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = File.join(Decko.gem_root, "public/assets")

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w[application-all.css application-print.css barebones.css
  #                                html5shiv-printshiv.js]

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # cache the list of set module objects on card objects
  config.cache_set_module_list = true
end
