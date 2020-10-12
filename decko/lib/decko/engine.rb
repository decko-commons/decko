
require "rails/all"
require "cardio"

# TODO: Move these to modules that use them
require "htmlentities"
require "coderay"
require "haml"
require "kaminari"
require "bootstrap4-kaminari-views"
require "diff/lcs"
require "builder"

require "decko"
require "cardio"

module Decko
  class Engine < ::Rails::Engine

    paths.add "app/controllers", with: "rails/controllers", eager_load: true
    paths.add "gem-assets",      with: "rails/assets"
    paths.add "config/routes.rb", with: "rails/engine-routes.rb"
    paths.add "lib/tasks", with: "#{::Decko.gem_root}/lib/tasks",
                           glob: "**/*.rake"
    # FIXME, belongs in parent
    paths["lib/tasks"] << "#{::Cardio.gem_root}/lib/tasks"

    initializer before: :set_autoload_paths do
    end

    initializer :set_load_path do
      # this code should all be in Decko somewhere, and it is now, gem-wize
      # Ideally railties would do this for us; this is needed for both use cases
      paths["request_log"]   = Decko.paths["request_log"]
      paths["log"]           = Decko.paths["log"]
      paths["lib/tasks"]     = Decko.paths["lib/tasks"]
      paths["config/routes.rb"] = Decko.paths["config/routes.rb"]
      paths["lib"]           = Decko.paths["lib"]
    end
  end
end
