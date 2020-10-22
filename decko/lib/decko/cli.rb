require "rbconfig"
require "pathname"
require "application_config" unless defined?(ApplicationConfig)

# If we are inside a Decko/Card application (have a parent with
# config/application.rb, therefore any rails and use card commands
# otherwise we are decko new and decko/commands.rb should handle it.
# The first case here is in app, replaces script_loader method
if defined?(APP_CONF) || APP_CONF = ApplicationConfig.find_app_config
  require APP_CONF
  require File.expand_path("../boot", APP_CONF)
  require 'decko/commands'

else
  require "rails/ruby_version_check"
  Signal.trap("INT") { puts; exit(1) }

#  if ARGV.first == 'plugin'
#    ARGV.shift
#    require 'decko/commands/plugin_new'
#  else
#  end
end
require "decko/commands/application"

