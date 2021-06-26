# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-cucumber" do |s, d|
  s.summary = "cucumber support for decko monkeys"
  s.description = ""

  d.depends_on ["cucumber",               ">= 5"],
               ["cucumber-rails",       ">= 2.3"],
               ["cucumber-expressions", ">= 8.3"],
               ["database_cleaner",   ">= 2.0.1"], # used by cucumber for db transactions
               "email_spec",
               "launchy", # lets cucumber launch browser windows
               ["capybara", ">= 3.35"], # see comments in web_steps.rb
               "capybara-puma",
               "rspec",
               "webdrivers",
               ["simplecov", ">= 0.21"]
end
