# -*- encoding : utf-8 -*-

require "email_spec"
require "email_spec/cucumber"

Before do
  Cardio.seed_test_db
end

at_exit do
  Cardio.seed_test_db
end

Capybara.configure do |config|
  # see https://github.com/teamcapybara/capybara#exactness
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
#   require "rack/handler/puma"
#   options.merge! Host: host, Port: port, Threads: "0:1", workers: 0, daemon: false
#   Rack::Handler::Puma.run app, **options
# end
