require "cardio/script_loader"

# FIXME: get the command name (card/decko) from $0 ($COMMAND ?)
command = "card"
path = command == "card" ? "cardio" : command # alias card -> cardio paths
# If we are inside a Card application this method performs an exec and thus
# the rest of this script is not run.
Cardio::ScriptLoader.exec_script! command

require "rails/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

# if ARGV.first == 'plugin'
#  ARGV.shift
#  require "#{path}/commands/plugin_new"
# else

# end
# FIXME: if path/... not there, use "cardio" (skip aliasing above?)
require "#{path}/commands/application"
