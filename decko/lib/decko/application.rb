# -*- encoding : utf-8 -*-

require "action_controller/railtie"
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

    def config
      @config ||= super.tap do |config|
        # config.load_defaults "6.0"
        # config.active_record.raise_in_transactional_callbacks = true

        config.allow_concurrency = false
        config.assets.enabled = false
        config.assets.version = "1.0"

        config.filter_parameters += [:password]
        config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
        decko_path_defaults config.paths
      end
    end

    private

    def decko_path_defaults paths
      paths.add "decko/config/environments",
                with: File.join(Decko.gem_root, "config/environments"),
                glob: "#{Rails.env}.rb"

      return if paths["config/routes.rb"].existent.present?

      paths.add "config/routes.rb",
                with: File.join(Decko.gem_root, "rails/application-routes.rb")
    end
  end
end
