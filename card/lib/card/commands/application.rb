# -*- encoding : utf-8 -*-

require "rails/generators"
require File.expand_path("../../generators/card/card_generator", __FILE__)

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

CardGenerator.start
