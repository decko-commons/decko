# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
warn "DECKO1.1 #{__LINE__} B:#{base}, #{base.instance}"
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
warn "DECKOa1.2 #{__LINE__} B:#{base}, #{base.called_from}"
        super # super is Cardio::App
warn "DECKOa2.3 #{__LINE__} appdir top level next"
      end
    end

    def configure &block
warn "DECKO configure #{block_given?}"
      super do
warn "CONFIGD3 #{__LINE__} #{self} #{self.class} #{self.config} #{config} bg:#{block_given?} in configure DECKO #{to_s}"

        instance_eval &block if block_given?

warn "CONFIGD4 #{__LINE__} #{config} in configure DECKO #{to_s}"
warn "PATHSD5 #{__LINE__} #{paths} #{config} #{config.paths}"
        #paths = config.paths
warn "DECKO6 config appl"
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

        config.autoloader = :zeitwerk
        config.load_default = "6.0"
        config.i18n.enforce_available_locales = true

        config.allow_concurrency = false
        config.assets.enabled = false
        config.assets.version = "1.0"

warn "DECKO7: #{__LINE__} super #{block_given?} (yield) #{config}"
        yield config if block_given?
warn "DECKO8: #{__LINE__} after yield #{config}"

        config.filter_parameters += [:password]

warn "DECKO9: #{__LINE__} AUTOLOAD alp #{config} decko #{Dir["#{Decko.gem_root}/lib"]}"
        config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

        #ActiveSupport.run_load_hooks :before_configuration, app

        paths.add "files"

        paths["app/models"] = []
        paths["app/mailers"] = []

        unless paths["config/routes.rb"].existent.present?
          Cardio.add_path "config/routes.rb",
                   with: "rails/application-routes.rb"
        end

warn "PATHSD10 #{paths} #{__LINE__} #{config} #{config.paths}"
warn "DECKO11 #{__LINE__} #{app}"
warn "DECKO12 #{__LINE__} #{config} done configure"
      end
    end

    PATH = "lib/decko/config/environments"

    initializer :decko_config_path,
                before: :load_environment_config do
warn "PATH: env path #{PATH}"
      paths.add PATH, with: PATH, glob: "#{Rails.env}.rb", root: Decko.gem_root
    end

    initializer :decko_load_config,
                after: :load_card_config do
warn "DECKO initting #{paths} #{PATH} #{paths[PATH]} #{paths[PATH].existent.map(&:to_s)*", "}"
      paths[PATH].existent.each do |environment|
warn "DECKO #{__LINE__} load env #{environment}"
        require environment
      end
    end
  end
end
