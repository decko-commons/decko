require "rails/generators"
require File.expand_path("../../generators/decko/decko_generator", __FILE__)

if ARGV.first != "new"
raise "From #{__FILE__}"
  #ARGV[0] = "--help"
else
  ARGV.shift
end
raise "From #{__FILE__}"

DeckoGenerator.start
