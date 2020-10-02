# -*- encoding : utf-8 -*-

# no card generator new templates
require "generators/card"

if ARGV.first != "new"
warn "From #{ARGV.first} #{__FILE__}"
  #ARGV[0] = "--help"
else
  cmd = ARGV.shift
end

warn "run cardio new command"
require "cardio/application"

require "cardio/commands"
Cardio::Commands.run_new
