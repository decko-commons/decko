# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-cypress" do |s, d|
  s.summary = "cypress integration for decko development"
  s.description = ""
  d.depends_on ["cypress-on-rails", "~> 1.4"]
end
