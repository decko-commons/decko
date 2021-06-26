# -*- encoding : utf-8 -*-

require "email_spec"
require "email_spec/cucumber"

World(RSpec::Matchers)
require "rspec-html-matchers"
World(RSpecHtmlMatchers)

Before("@background-jobs or @delayed-jobs or @javascript") do
  Cardio.seed_test_db
end

Before("not @background-jobs", "not @delayed-jobs", "not @javascript") do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

After("not @background-jobs", "not @delayed-jobs", "not @javascript") do
  DatabaseCleaner.clean
end

at_exit do
  Cardio.seed_test_db
end
# frozen_string_literal: true

Before("@javascript") do
  @javascript = true
end

Capybara.configure do |config|
  config.match = :prefer_exact
end

Before do
  Card::Cache.reset
  # TODO: try restore/prepopulate
end

Before("@simulate-setup") do
  Card::Auth.simulate_setup!
end

After("@simulate-setup") do
  Card::Auth.simulate_setup! false
end

# Capybara.register_server :puma do |app, port, host, options={}|
#   options.merge! Host: host, Port: port, Threads: "0:1", workers: 0, daemon: false
#   Rack::Handler::Puma.run app, **options
# end
