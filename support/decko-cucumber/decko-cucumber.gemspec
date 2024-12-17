# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-cucumber" do |s, d|
  required_ruby_version = ">= 3.0.0"
  s.summary = "cucumber support for decko monkeys"
  s.description = ""

  d.depends_on ["cucumber-rails",         "~> 2.3"],
               ["cucumber-create-meta", "!= 6.0.3"],
               ["database_cleaner",       "~> 2.0"], # resetting db between tests
               ["email_spec",             "~> 2.2"], # for email-related tests
               ["launchy",                "~> 2.5"], # lets cucumber launch browser
               ["capybara-puma",          "~> 1.0"], # use puma server
               ["puma",                 "!= 6.0.0"],
               ["webdrivers",             "~> 5.2"],
               ["selenium-webdriver",     "=4.9.0"], # 4.9.1+ requires ruby 3
               ["rspec-html-matchers",    "~> 0.9"],
               ["rspec",                 "~> 3.10"],
               ["simplecov",             "~> 0.21"]
end
