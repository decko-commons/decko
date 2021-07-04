require "cardio/all"

module Cardio
  class Application < Rails::Application
    config.wiggy_biggy = "jiggly"
  end
end

Bundler.require :default, *Rails.groups

# these two have railties and likely need to be loaded before application so they
# don't override configuration later
require "haml"
require "kaminari"

require "bootstrap4-kaminari-views"
