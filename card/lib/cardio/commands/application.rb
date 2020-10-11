# -*- encoding : utf-8 -*-

command = (cmd=$0) =~ /\/([^\/]+)$/ ? $1 : cmd

if command != 'new'
  require 'rails'

  module Cardio
    module Commands
      class Application < ::Rails::Application
      end
    end
  end

  require "cardio/commands/#{command}_command"
else
  ARGV[0] = '--help'
  require "cardio/commands"
end

