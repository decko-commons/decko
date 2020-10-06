# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-cucumber" do |s, _d|
  s.summary = "cucumber support for decko monkeys"
  s.description = ""

  [
    ["cucumber", "~> 3.1"],
    ["cucumber-rails"],
    ["cucumber-expressions"],
    ["database_cleaner", "~> 1.5"], # used by cucumber for db transactions
    ["email_spec"],
    ["launchy"], # lets cucumber launch browser windows

    ["capybara", "~> 2.18"], # see comments in web_steps.rb
    ["capybara-puma"],
    ["chromedriver-helper", "~> 2.1.0"],
    ["rspec"],
    ["selenium-webdriver", "3.141.0"],

    ["simplecov"] # test coverage
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
