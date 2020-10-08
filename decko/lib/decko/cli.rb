require "rbconfig"
require "cardio/script_loader"

# If we are inside an application this method performs an exec and thus
# the rest of this script is not run.
Cardio::ScriptLoader.exec_script! :decko

require "rails/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

# ARGV.shift
# require 'decko/commands/plugin_new'
#else

require "decko/commands/application"
#end
