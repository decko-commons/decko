# -*- encoding : utf-8 -*-

# this app is started for card (rails extension) commands

require File.expand_path("../environment", APP_CONF)
require "cardio/commands"
# no card generator new templates
case ARGV.first
when 'generator'
  require "generators/card"
when 'new'
  #ARGV[0] = "--help"
else

  require "cardio/commands"

  cmd = ARGV.shift
  #Cardio::Commands.run_new
end

