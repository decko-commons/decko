# -*- encoding : utf-8 -*-
require "email_spec"
require "email_spec/cucumber"

Capybara.configure do |config|
  config.match = :prefer_exact
end

Before do
  Card::Cache.reset
  Card::Lexicon.reset # TODO: obviate this
end
