Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    def config
      super.tap { |c| Cardio.set_config c }
    end
  end
end
