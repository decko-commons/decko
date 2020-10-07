# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application
    class << self
      include RailsConfigMethods

      def inherited base
        super
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end
  end
end
