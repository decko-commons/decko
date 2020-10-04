# -*- encoding : utf-8 -*-

# no card generator new templates
require "generators/card"

if ARGV.first != "new"
  #ARGV[0] = "--help"
else
  cmd = ARGV.shift
end

require "cardio/application"

require "cardio/commands"
Cardio::Commands.run_new
