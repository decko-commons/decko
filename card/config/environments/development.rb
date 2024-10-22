# -*- encoding : utf-8 -*-

Cardio.application.class.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.view_cache = false
  config.cache_log_level = :debug
  config.eager_load = false

  config.asset_refresh = :eager
  config.compress_assets = false

  config.sql_comments = true

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # See everything in the log (default is :info)
  config.log_level = :debug

  # if false, most rendering errors will be rescued and made visible only
  # in the nest where the error occurred
  config.raise_all_rendering_errors = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  # config.assets.compress = false
  #
  #   # Expands the lines which load the assets
  #   config.assets.debug = false
  #
  #   # This needs to be on for tinymce to work, because several important files
  #     (themes, etc) are only served statically
  #   config.serve_static_files = ENV['STATIC_ASSETS'] || true
  #
  #   # Setting a bogus directory so rails won't find public/assets in dev mode.
  #   # Normally you could skip that by not serving static assets, but that breaks
  #     tinymce (see above)
  #   config.assets.prefix = "dynamic-assets"

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #  config.active_record.auto_explain_threshold_in_seconds = 0.5

  #  if File.exist?(File.join(Rails.root,'tmp', 'debug.txt'))
  #    require 'ruby-debug'
  #    Debugger.wait_connection = true
  #    Debugger.start_remote
  #    File.delete(File.join(Rails.root,'tmp', 'debug.txt'))
  #  end

  config.action_mailer.perform_deliveries = false

  # config.session_store :cookie_store
end

# Paperclip.options[:command_path] = "/opt/local/bin"
