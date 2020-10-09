# -*- encoding : utf-8 -*-

# no card generator new templates
require "generators/card"

if ARGV.first != "new"
raise "why not in script?"
  ARGV[0] = "--help"
else
  cmd = ARGV.shift
end

#require "cardio/application"
#Cardio::Application
  #initializer before: :set_load_path do
  #end
#end

require "cardio/commands"
Cardio::Commands.run_new
