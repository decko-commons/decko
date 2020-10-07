# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    class << self
      include RailsConfigMethods

      def inherited base
warn "CARDAPP: #{__LINE__} Rappclass:#{Rails.app_class} #{base}"
        Cardio.default_configs
        super
        add_lib_to_load_path!(find_root(base.called_from))
warn "CARDAPP: #{__LINE__} Rappclass:#{Rails.app_class} #{base}"
      end
    end

    ENVCONF = "lib/card/config/environments"

    initializer :load_card_configuration,
         before: :load_environment_config, group: :all do
warn "CARDAPP: #{__LINE__} configure"
      Cardio.load_card_environment
      #config.autoloader = :zeitwerk
      #config.load_default = "6.0"
      #config.i18n.enforce_available_locales = true
warn "CARDAPP #{__LINE__} paths #{paths} #{paths.values.map(&:to_a).flatten*"\n"}"
warn "CARDAPP: #{__LINE__} loaded card env #{config} #{paths}"
      path = File.join(Cardio.gem_root, ENVCONF, "#{Rails.env}.rb")
#warn "CARDAPP #{__LINE__} paths #{paths} #{paths.keys.map {|k| "#{k}: #{paths[k].to_a*", "}"}*"\n"}\n#{paths.values.map(&:to_a).map(&:length).flatten*"\n"}"
      paths.add ENVCONF, with: path
warn "CARDAPP: #{__LINE__} #{ENVCONF} #{path} #{paths{ENVCONF}.values.map(&:to_a)*", "}"
    end

    initializer :load_card_environment,
         after: :load_card_configuration, group: :all do
      paths[ENVCONF].existent.each do |environment|
warn "CARDAPP: #{__LINE__} env #{environment}"
        require environment
      end
    end

    initializer :connect_on_load,
         after: :load_environment_config do
warn "CARDAPP: #{__LINE__} loaded env config"
      Cardio.load_rails_environment
warn "CARDAPP: #{__LINE__} setup AR on load"
      ActiveSupport.on_load(:active_record) do
warn "CARDAPP: #{__LINE__} do on load stuff?"
        Cardio.connect_on_load
warn "CARDAPP: #{__LINE__} establish conn"
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
warn "CARDAPP: #{__LINE__} card before"
        ActiveSupport.run_load_hooks(:before_card)
warn "CARDAPP: #{__LINE__} done AR on load"
      end
warn "CARDAPP: #{__LINE__}"
      # ActiveSupport.on_load(:after_initialize) do
      #   # require "card" if Cardio.load_card?
      #   Card if Cardio.load_card?
      # rescue ActiveRecord::StatementInvalid => e
      #  ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
      # end
    end

    #def add_path path, options={}
#warn "CARDAPP: #{__LINE__} configure"
      #root = root_path_option options
      #options[:with] = File.join(root, (options[:with] || path))
      #paths.add path, options
    #end
  end
end
