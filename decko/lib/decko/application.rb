# -*- encoding : utf-8 -*-

require "cardio/all"
require "action_controller/railtie"
require "decko/railtie"
require "cardio/application"

# require_relative "config/initializers/sedate_parser"
require "decko/engine"

# The application class from which decko applications inherit
Decko::Application = Rails::Application
