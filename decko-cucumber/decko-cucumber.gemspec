# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-cucumber" do |s, _d|
  s.summary = "cucumber support for decko monkeys"
  s.description = ""

  [
    ["card-mod-monkey"],
    ["capybara-puma"],
    ["cucumber", "~> 3.1"],
    ["cucumber-rails"],
    ["cucumber-expressions"],
    ["capybara"],
    ["selenium-webdriver", "3.141.0"],
    ["chromedriver-helper", "~> 2.1.0"],
    ["database_cleaner", "~> 1.5"], # used by cucumber for db transactions
    # gem 'capybara-webkit'
    ["launchy"] # lets cucumber launch browser windows
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
