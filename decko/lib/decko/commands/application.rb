require "rails/generators"
require File.expand_path("../../generators/decko/decko_generator", __FILE__)

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

# this is the case when not in a decko application directory
# generate a new decko application directory
DeckoGenerator.start
