# -*- encoding : utf-8 -*-

# no card generator new templates
require "card/commands"
require "generators/card"

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  cmd = ARGV.shift
end

Card::Commands.run_new
