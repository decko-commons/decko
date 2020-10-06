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
                #after: :bootstrap, group: :all do
                before: :load_environment_config, group: :all do
                #before: :connect_on_load, group: :all do
      add_path "lib/card/config/environments", glob: "#{Rails.env}.rb", root: Cardio.gem_root
      paths["lib/card/config/environments"].existent.each do |environment|
warn "load env #{environment}"
        require environment
      end
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        c=ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
      end
      # ActiveSupport.on_load(:after_initialize) do
      #   # require "card" if Cardio.load_card?
      #   Card if Cardio.load_card?
      # rescue ActiveRecord::StatementInvalid => e
      #  ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
      # end
      ActiveSupport.on_load(:before_card) do
      end
      ActiveSupport.on_load(:after_application_record) do
warn "load ap rec trig, load card"
        Cardio.load_card!
      end
    end

    def configure &block
      super do
        instance_eval &block if block_given?

        config.load_default = "6.0"
        Cardio.load_card_environment
        #Cardio.set_config
        #Cardio.set_paths paths

        #config.autoloader = :zeitwerk # included in "6.0"
        config.i18n.enforce_available_locales = true # maybe this too
      end
    end

    initializer :load_card_config,
                before: :load_environment_config, group: :all do
      #Cardio.load_card_environment
    end

    initializer :load_card_config_initializers,
                after: :load_card_config, group: :all do
      Cardio.load_rails_environment
      paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
      Cardio.connect_on_load
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
