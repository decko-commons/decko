# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift File.expand_path(
  "../../mod/platypus/vendor/capybara-select2/lib", __dir__
)
require "capybara-select2"

require File.expand_path("support/card_spec_loader.rb", __dir__)
CardSpecLoader.init

require "rr"

CardSpecLoader.prefork do
  CardSpecLoader.rspec_config do |config|
    # require 'card-rspec-formatter'
    config.mock_with :rr

    config.mock_with :rspec do |mocks|
      mocks.syntax = %i[should expect]
      mocks.verify_partial_doubles = true
    end
    config.expect_with :rspec do |c|
      c.syntax = %i[should expect]
    end
  end
end

require "simplecov"

CardSpecLoader.helper

module ActiveSupport
  class Logger
    def rspec msg, console_text=nil
      if Thread.current["logger-output"]
        Thread.current["logger-output"] << msg
      else
        puts console_text || msg
      end
    end
  end
end
