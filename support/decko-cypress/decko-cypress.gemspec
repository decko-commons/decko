# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-cypress" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.summary = "cypress integration for decko development"
  s.description = ""
  d.depends_on ["cypress-on-rails", "~> 1.4"]
end
