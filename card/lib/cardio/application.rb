require "cardio/all"

Bundler.require :default, *Rails.groups

# these two have railties and likely need to be loaded before application so they
# don't override configuration later
require "haml"
require "kaminari"

require "bootstrap4-kaminari-views"

module Cardio
  # handles config and path defaults
  class Application < Rails::Application
    initializer "card.load_environment_config",
                before: :load_environment_config, group: :all do
      paths["card/config/environments"].existent.each do |environment|
        require environment
      end
    end
  end
end
