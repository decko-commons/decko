# -*- encoding : utf-8 -*-
Decko.application.class.configure do
  # Edit at your own peril - it's recommended to regenerate this file
  # in the future when you upgrade to a newer version of Cucumber.

  config.eager_load = false

  config.machine_refresh = :never

  # IMPORTANT: Setting config.cache_classes to false is known to
  # break Cucumber's use_transactional_fixtures method.
  # For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
  config.cache_classes = true

  config.prepopulate_cache = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :log

  config.log_level = :debug

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.use_transactional_fixtures = false

  config.rescue_all_in_controller = false
  config.raise_all_rendering_errors = true
end
