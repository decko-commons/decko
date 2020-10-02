# -*- encoding : utf-8 -*-

warn "SPEC: #{__LINE__}"
require File.expand_path("../support/card_spec_loader.rb", __FILE__)
warn "SPEC: #{__LINE__}"
CardSpecLoader.init

require "rr"
warn "SPEC: #{__LINE__}"
CardSpecLoader.prefork do
  CARD_TEST_SEED_PATH = File.expand_path("../../db/seed/test/fixtures", __FILE__)

warn "SPEC PRE: #{__LINE__}"
  CardSpecLoader.rspec_config do |config|
    # require 'card-rspec-formatter'
    config.mock_with :rr

    config.mock_with :rspec do |mocks|
      mocks.syntax = [:should, :expect]
      mocks.verify_partial_doubles = true
    end
    config.expect_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
  end
warn "SPEC PRE: #{__LINE__}"

  Card["*all+*style"].ensure_machine_output
  Card["*all+*script"].ensure_machine_output
  (ie9 = Card[:script_html5shiv_printshiv]) && ie9.ensure_machine_output
warn "SPEC PRE: #{__LINE__}"
end

CardSpecLoader.each_run do
  # This code will be run each time you run your specs.
  require "simplecov"
end

CardSpecLoader.helper

class ActiveSupport::Logger
  def rspec msg, console_text=nil
    if Thread.current["logger-output"]
      Thread.current["logger-output"] << msg
    else
      puts console_text || msg
    end
  end
end
