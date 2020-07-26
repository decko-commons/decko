# -*- encoding : utf-8 -*-
require "email_spec"
require "email_spec/cucumber"

Capybara.configure do |config|
  config.match = :prefer_exact
end

Before do
  Card::Name.reset_hashes # TODO: obviate this
  Card::Cache.reset
end
