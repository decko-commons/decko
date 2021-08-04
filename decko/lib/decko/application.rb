# -*- encoding : utf-8 -*-

require "cardio/all"
require "action_controller/railtie"
require "decko/railtie"
require "cardio/application"

# require_relative "config/initializers/sedate_parser"

module Decko
  # The application class from which all decko applications inherit
  class Application < Cardio::Application
    require "decko/engine"

    initializer "decko.load_environment_config",
                after: "card.load_environment_config", group: :all do
      paths["decko/config/environments"].existent.each do |environment|
        require environment
      end
    end

    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end
  end
end
