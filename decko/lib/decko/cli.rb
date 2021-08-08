require "rbconfig"
require "decko/script_decko_loader"

# If we are inside a Decko application this method performs an exec and thus
# the rest of this script is not run.
Decko::ScriptDeckoLoader.exec!

require "rails/ruby_version_check"
Signal.trap("INT") { exit(1) }

require "decko/commands/application"
