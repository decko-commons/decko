require "rbconfig"
require "colorize"
require "cardio/script_loader"

# If we are inside a Decko application this method performs an exec and thus
# the rest of this script is not run.
Cardio::ScriptLoader.exec!

require "rails/ruby_version_check"
Signal.trap("INT") { exit(1) }

require "cardio/commands/application"
