workers Integer(ENV["WEB_CONCURRENCY"] || 0)
min_threads_count = Integer(ENV["RAILS_MIN_THREADS"] || 1)
max_threads_count = Integer(ENV["RAILS_MAX_THREADS"] || 1)
threads min_threads_count, max_threads_count

preload_app!

# rackup      DefaultRackup
port        ENV["PORT"]     || 3000
environment ENV["RACK_ENV"] || "development"
