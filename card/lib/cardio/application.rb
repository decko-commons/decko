Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    initializer "cardio.load_default_config",
                before: :load_environment_config, group: :all do
      binding.pry
      Cardio.set_config config
    end
  end
end
