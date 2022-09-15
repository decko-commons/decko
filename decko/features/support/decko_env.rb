# -*- encoding : utf-8 -*-

require "email_spec"
require "email_spec/cucumber"

World(RSpec::Matchers)
require "rspec-html-matchers"
World(RSpecHtmlMatchers)

Before do
  Cardio::Utils.seed_test_db
end

at_exit do
  Cardio::Utils.seed_test_db
end

Before("@javascript") do
  @javascript = true
end

Capybara.configure do |config|
  config.match = :prefer_exact
end

Before do
  Card::Cache.reset
  Card::Set::Self::Role.clear_rolehash
  # TODO: try restore/prepopulate
end

Before("@simulate-setup") do
  Card::Auth.simulate_setup!
end

After("@simulate-setup") do
  Card::Auth.simulate_setup! false
end

# Capybara.register_server :puma do |app, port, host, options={}|
#   require "rack/handler/puma"
#   options.merge! Host: host, Port: port, Threads: "0:1", workers: 0, daemon: false
#   Rack::Handler::Puma.run app, **options
# end
