# -*- encoding : utf-8 -*-

command = (cmd=$0) =~ /\/([^\/]+)$/ ? $1 : cmd

if command != 'new'
  require 'cardio/script_loader'

  module Cardio
    module Commands
      require 'rails'

      class Application < ::Rails::Application
        def inherited base
          Rails.app_class = base
        end
        initializer :set_app_path do
        end
      end
    end
  end

  #require Cardio::ScriptLoader.command_path
else
  ARGV[0] = '--help'
  require "cardio/commands"
end

