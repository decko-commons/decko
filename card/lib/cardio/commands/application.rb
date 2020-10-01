# -*- encoding : utf-8 -*-

# no card generator new templates
require "cardio/commands"
require "generators/card"

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  cmd = ARGV.shift
end

Cardio::Commands.run_new
