# -*- encoding : utf-8 -*-

command = (cmd=$0) =~ /\/([^\/]+)$/ ? $1 : cmd

if command != 'new'
  module Cardio
    module Commands
      require 'rails'

      class Application < ::Rails::Application
      end
    end
  end

  PATH_ALIAS = { 'cardio' => 'card', 'decko' => 'deck' }

  command = PATH_ALIAS[command] unless PATH_ALIAS[command].nil?
  base = (command == 'deck') ? 'decko' : 'cardio'
  require "#{base}/commands/#{command}_command"
else
  ARGV[0] = '--help'
  require "cardio/commands"
end

