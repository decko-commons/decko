require "cardio/all"

Bundler.require :default, *Rails.groups

# these two have railties and need to be loaded before application
require "haml"
require "kaminari"

require "bootstrap4-kaminari-views"

Cardio::Application = Rails::Application
