DECKO_RAILS_GEM_ROOT = File.expand_path("../../..", __FILE__)

require "rails/all"
require "decko/engine"

module Decko
  module Rails # not sure we need this
    class << self
      def gem_root
        DECKO_RAILS_GEM_ROOT
      end
    end
  end

  if defined? ::Rails::Railtie
    class Railtie < ::Rails::Railtie
      initializer before: :load_config_initializers do
        Cardio.set_config ::Rails.application.config
        Cardio.set_paths ::Rails.application.paths
      end

      rake_tasks do |_app|
        load "tasks/decko.rake"
        load "tasks/card.rake"
      end
    end
  end
end
