# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"

require_relative "config/initializers/sedate_parser"

module Decko
  # The application class from which all decko applications inherit
  class Application < Cardio::Application
    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    initializer "decko.load_environment_config",
                before: :load_environment_config, group: :all do
      paths["lib/decko/config/environments"].existent.each do |environment|
        require environment
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
      decko_root_path paths, "lib/decko/config/environments", glob: "#{Rails.env}.rb"
      return if paths["config/routes.rb"].existent.present?

      decko_root_path paths, "config/routes.rb", with: "rails/application-routes.rb"
    end

    def decko_root_path paths, path, options
      options[:with] = File.join(Decko.gem_root, (options[:with] || path))
      paths.add path, options
    end
  end
end
