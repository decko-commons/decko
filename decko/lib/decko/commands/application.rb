require "rails/generators"
require File.expand_path("../../generators/decko/deck_generator", __FILE__)

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

DeckoGenerator.start
