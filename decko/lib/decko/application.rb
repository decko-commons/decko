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
        cardio_defaults
      end
    end

    initializer "decko.load_defaults", before: :load_environment_config, group: :all do
      decko_path_defaults
      decko_config_defaults
      decko_environment_defaults
    end

    private

    def decko_path_defaults
      paths["app/models"] = []
      paths["app/mailers"] = []
      paths["app/controllers"] = []

      paths.add "files"

      add_path "lib/decko/config/environments",
               glob: "#{Rails.env}.rb", root: Decko.gem_root

      return if paths["config/routes.rb"].existent.present?

      add_path "config/routes.rb",
               with: "rails/application-routes.rb", root: Decko.gem_root
    end

    def decko_environment_defaults
      paths["lib/decko/config/environments"].existent.each do |environment|
        require environment
      end
    end

    def decko_config_defaults
      # config.load_defaults "6.0"
      config.autoloader = :zeitwerk
      config.i18n.enforce_available_locales = true
      # config.active_record.raise_in_transactional_callbacks = true

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"

      config.filter_parameters += [:password]
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
    end
  end
end
