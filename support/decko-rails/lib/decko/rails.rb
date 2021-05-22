DECKO_RAILS_GEM_ROOT = File.expand_path("../..", __dir__)

require "rails/all"
require "decko/engine"

module Decko
  # not sure we need this
  module Rails
    class << self
      def gem_root
        DECKO_RAILS_GEM_ROOT
      end
    end
  end

  if defined? ::Rails::Railtie
    class Railtie < ::Rails::Railtie
      initializer "decko-rails.load_task_path",
                  before: "decko.engine.load_config_initializers" do
        Cardio.set_config ::Rails.application.config
        Cardio.set_paths ::Rails.application.paths
      end

      rake_tasks do |_app|
        # for some reason this needs the 'decko/',
        # can't get lib/tasks change right by this time?
        load "decko/tasks/decko.rake"
        load "card/tasks/card.rake"
      end
    end
  end
end
