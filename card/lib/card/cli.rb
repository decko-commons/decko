require "rbconfig"
require "card/commands/application"
require "card/script_card_loader"

# If we are inside a Card application this method performs an exec and thus
# the rest of this script is not run.
Card::ScriptCardLoader.exec_script_card!

require "rails/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

# if ARGV.first == 'plugin'
#  ARGV.shift
#  require 'card/commands/plugin_new'
# else

# end
