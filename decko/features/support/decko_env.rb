# -*- encoding : utf-8 -*-
require "email_spec"
require "email_spec/cucumber"

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
