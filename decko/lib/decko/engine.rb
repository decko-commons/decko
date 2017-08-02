
require "rails/all"
require "cardio"

# TODO: Move these to modules that use them
require "htmlentities"
require "recaptcha"
require "coderay"
require "haml"
require "kaminari"
require "bootstrap4-kaminari-views"
require "diff/lcs"
require "builder"

require "decko"

module Decko
  class Engine < ::Rails::Engine
    paths.add "app/controllers",  with: "rails/controllers", eager_load: true
    paths.add "gem-assets",       with: "rails/assets"
    paths.add "config/routes.rb", with: "rails/engine-routes.rb"
    paths.add "lib/tasks", with: "#{::Decko.gem_root}/lib/decko/tasks",
                           glob: "**/*.rake"
    paths["lib/tasks"] << "#{::Cardio.gem_root}/lib/card/tasks"
    paths.add "lib/decko/config/initializers",
              with: File.join(Decko.gem_root, "lib/decko/config/initializers"),
              glob: "**/*.rb"

    initializer "decko.engine.load_config_initializers",
                after: :load_config_initializers do
      paths["lib/decko/config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    initializer "engine.copy_configs",
                before: "decko.engine.load_config_initializers" do
      # this code should all be in Decko somewhere, and it is now, gem-wize
      # Ideally railties would do this for us; this is needed for both use cases
      Engine.paths["request_log"]   = Decko.paths["request_log"]
      Engine.paths["log"]           = Decko.paths["log"]
      Engine.paths["lib/tasks"]     = Decko.paths["lib/tasks"]
      Engine.paths["config/routes"] = Decko.paths["config/routes"]
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      ActiveSupport.on_load(:after_initialize) do
        begin
          require_dependency "card" unless defined?(Card)
        rescue ActiveRecord::StatementInvalid => e
          ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
        end
      end
    end
  end
end
