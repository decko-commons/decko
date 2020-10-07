# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"

Bundler.require :default, *Rails.groups

module Decko
  class Application < Cardio::Application
#    initializer :load_decko_environment_config,
#                before: :load_environment_config, group: :all do
#warn "DECKO #{__LINE__} before environ"
#    end

    class << self
      include Cardio::RailsConfigMethods

      def inherited base
warn "DECKO1.1 #{__LINE__} B:#{base}, #{base.instance}"
        super # super is Cardio::App
warn "DECKOa1.2 #{__LINE__} B:#{base}, #{base.called_from}"
        Rails.app_class = base
      end
    end

#    def add_path path, options={}
#      root = options.delete(:root) || Decko.gem_root
#      options[:with] = File.join(root, (options[:with] || path))
#      paths.add path, options
#    end

    initializer :decko_configure,
        before: :load_environment_config, group: :all do
warn "DECKO #{paths} #{__LINE__} #{paths.autoload_paths.map {|p| "#{p.keys*", "}"}.length}"
      #path = File.join(Decko.gem_root, "lib")
      paths.add "lib", root: Decko.gem_root
warn "DECKO added lib #{paths} #{__LINE__} #{paths.autoload_paths.map {|p| "#{p.keys*", "}"}.length}"
warn "DECKOa2.3 #{__LINE__} Rappclass:#{Rails.app_class} appdir top level next"
      config.load_default = "6.0"
      Cardio.set_paths
warn "DECKO configure #{__LINE__}"

      config.active_job.queue_adapter = :delayed_job
warn "DECKO: #{__LINE__} AUTOLOAD alp #{config} decko #{Dir["#{Decko.gem_root}/lib"]} ALP:#{config.autoload_paths.map(&:to_s)}"

      # any config settings below:
      # (a) do not apply to Card used outside of a Decko context
      # (b) cannot be overridden in a deck's application.rb, but
      # (c) CAN be overridden in an environment file

      # therefore, in general, they should be restricted to settings that
      # (1) are specific to the web environment, and
      # (2) should not be overridden
      # ..and we should address (c) above!

      # general card settings (overridable and not) should be in cardio.rb
      # overridable decko-specific settings don't have a place yet
      # but should probably follow the cardio pattern.

      config.i18n.enforce_available_locales = true
warn "DECKO CONFIGD4 (after CARDAPP) #{__LINE__} #{config} in configure"
warn "DECKO PATHSD5 #{__LINE__} #{paths} #{config} #{config.paths}"

      config.allow_concurrency = false
      config.assets.enabled = false
      config.assets.version = "1.0"
      # config.active_record.raise_in_transactional_callbacks = true
warn "DECKO configure #{__LINE__} i18n locals:#{config.i18n.enforce_available_locales}"

      config.filter_parameters += [:password]
warn "DECKO configure #{__LINE__}"

      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

warn "DECKO: #{__LINE__} AUTOLOAD alp #{config} decko #{Dir["#{Decko.gem_root}/lib"]} ALP:#{config.autoload_paths.length}"

      #ActiveSupport.run_load_hooks :before_configuration, app
      # Rails.autoloaders.log!
warn "DECKO #{__LINE__} ALMain:#{Rails.autoloaders.main}"
      #Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
      # paths configuration
warn "DECKO configure #{__LINE__}"

      paths.add "files"

      paths["app/models"] = []
      paths["app/mailers"] = []
warn "DECKO #{__LINE__} paths #{paths} #{paths.values.map(&:to_a).flatten*", "}"
#warn "DECKO #{__LINE__} paths #{paths} PathKs #{paths.keys.map {|k| "#{k}: #{paths[k].to_a.length}"}*"\n"}\nPVS:#{paths.values.map(&:to_a).map(&:length).flatten*", "}"

      unless paths["config/routes.rb"].existent.present?
        paths.add "config/routes.rb", with: "rails/application-routes.rb"
      end

warn "PATHSD10 #{paths} #{__LINE__} #{paths.autoload_paths.map {|p| "#{p.keys*", "}"}.length}"
    end

    PATH = "lib/decko/config/environments"
    initializer :decko_environment,
                after: :decko_configure, group: :all do
warn "DECKO #{paths} #{__LINE__} #{paths.autoload_paths.map {|p| "#{p.keys*", "}"}.length}"
      #ActiveSupport.run_load_hooks(:before_configuration, self)
warn "DECKO ENVIRONMENT #{__LINE__} load path (ALL)"
      path = File.join(Decko.gem_root, PATH, "#{Rails.env}.rb")
warn "DECKO ENVIRONMENT #{__LINE__} load path #{path}"
      paths.add PATH, with: path
warn "DECKO #{__LINE__} initting #{paths} #{PATH} #{paths[PATH].map(&:to_s)} #{paths[PATH].existent.length}"
      paths[PATH].existent.each do |environment|
warn "DECKO ENVIRONMENT #{__LINE__} load env #{environment}\n#{caller[0..12]*"\n"}"
        require environment
      end
    end
  end
end
