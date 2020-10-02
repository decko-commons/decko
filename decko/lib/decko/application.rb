# -*- encoding : utf-8 -*-

require "decko/engine"
require "cardio/application"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
        super
warn "ib Decko #{base}, #{base.called_from}, #{base.instance}"
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def config
      c = super
      return c if @configed
      @configed = true

warn "config decko ap"
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

      c.gem_root = Decko.gem_root
      c.autoloader = :zeitwerk
      c.load_default = "6.0"
      c.i18n.enforce_available_locales = true

      c.allow_concurrency = false
      c.assets.enabled = false
      c.assets.version = "1.0"

      c.filter_parameters += [:password]

warn "alp #{c} decko #{Dir["#{Decko.gem_root}/lib"]}"
      c.autoload_paths += Dir["#{Decko.gem_root}/lib"]

      c
    end

    def paths
      p = super
      return p if @pathinit
      @pathinit = true

      p.add "files"

      p["app/models"] = []
      p["app/mailers"] = []

      unless p["config/routes.rb"].existent.present?
        Cardio.add_path "config/routes.rb",
                 with: "rails/application-routes.rb"
      end

      p
    end
  end
end
