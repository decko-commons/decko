
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

module Decko
  class Engine < ::Rails::Engine
warn "DENGINE configure (loading) #{__LINE__}"

    paths.add "app/controllers", with: "rails/controllers", eager_load: true
    paths.add "gem-assets",      with: "rails/assets"
    paths.add "config/routes.rb", with: "rails/engine-routes.rb"
    paths.add "lib/tasks", with: "#{::Decko.gem_root}/lib/tasks",
                           glob: "**/*.rake"
    # FIXME, belongs in parent
    paths["lib/tasks"] << "#{::Cardio.gem_root}/lib/tasks"
warn "DENGINE configure #{__LINE__} #{config} #{paths}"
    paths.add "lib/config/initializers", glob: "**/*.rb",
        with: File.join(Decko.gem_root, "lib/decko/config/initializers")
warn "DENGINE #{__LINE__} paths #{paths} #{paths.values.map(&:to_a).flatten*"\n"}"

    paths["lib/config/initializers"].existent.sort.each do |initializer|
warn "DENGINE initializer #{__LINE__} #{initializer}"
      load(initializer)
    end
warn "DENGINE configure #{__LINE__}"

#=begin
    initializer "decko.engine.configure_paths",
         before: :load_environment_hook, group: :all do
      # this code should all be in Decko somewhere, and it is now, gem-wize
      # Ideally railties would do this for us; this is needed for both use cases
warn "DENGINE initializer all grp #{__LINE__}"
      paths["request_log"]   = Decko.paths["request_log"]
      paths["log"]           = Decko.paths["log"]
      paths["lib/tasks"]     = Decko.paths["lib/tasks"]
      paths["config/routes.rb"] = Decko.paths["config/routes.rb"]
      paths["lib"]           = Decko.paths["lib"]
      #config.autoload_paths = Decko.config.autoload_paths
warn "DENGINE: LAST #{__LINE__} AUTOLOAD alp #{config} decko #{Dir["#{Decko.gem_root}/lib"]} ALP:#{config.autoload_paths.map(&:to_s)}"
warn "DENGINE #{Engine.paths} #{paths} #{Cardio.paths} #{__LINE__}"
#    end

#    initializer "decko.engine.load_configuration",
#        after: :load_card_environment, group: :all do
warn "DENGINE: LAST #{__LINE__} AUTOLOAD alp #{config} decko #{Dir["#{Decko.gem_root}/lib"]} ALP:#{config.autoload_paths.map(&:to_s)}"
    end
#=end
  end
end
