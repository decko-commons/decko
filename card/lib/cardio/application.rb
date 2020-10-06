# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
        ActiveSupport.run_load_hooks(:load_active_record, base.instance)
        ActiveSupport.run_load_hooks(:before_card)
      end
    end

    initializer :load_card_environment_config,
                before: :load_environment_config, group: :all do
      add_path "lib/card/config/environments",
               glob: "#{Rails.env}.rb", root: Cardio.gem_root
      paths["lib/card/config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        c=ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
        Cardio.connect_on_load
        Cardio.load_rails_environment
      end
    end

    def configure &block
      super do
        instance_eval &block if block_given?

        #config.autoloader = :zeitwerk
        #config.load_default = "6.0"
        #config.i18n.enforce_available_locales = true

        #Cardio.set_paths paths
        #Cardio.set_config
        Cardio.load_card_environment
      end
    end

    def root_path_option options
      options.delete(:root) || Cardio.gem_root
    end

    def add_path path, options={}
      root = root_path_option options
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end
  end
end
