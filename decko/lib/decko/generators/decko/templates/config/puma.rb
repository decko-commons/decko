workers Integer(ENV['WEB_CONCURRENCY'] || 1)
min_threads_count = Integer(ENV['RAILS_MIN_THREADS'] || 1)
max_threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 1)
threads min_threads_count, max_threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  # ARDEP: maybe register storage managers with establish_connection action?
  ActiveRecord::Base.establish_connection
end
