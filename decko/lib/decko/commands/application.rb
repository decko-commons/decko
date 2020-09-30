require "rails/generators"
require File.expand_path("../../generators/decko/decko_generator", __FILE__)

if ARGV.first != "new"
warn "in decko, not new #{ARGV}"
  ARGV[0] = "--help"
else
  ARGV.shift
end

DeckoGenerator.start
