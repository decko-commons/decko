# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "cypress" do |s, _d|
  s.summary = "cypress integration for decko development"
  s.description = ""
  s.add_runtime_dependency "cypress-on-rails", "~> 1.4"
end
